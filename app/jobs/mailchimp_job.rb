# Mailchimp is used to send mailings to members and alumni, for this reason
# this functionality requires two Mailchimp lists. One list for members and
# one for alumni. These lists should be created manually.

# To distinct students from eachother we will add some custom meta data such
# as studies. Furthermore we can create groups where the member itself can
# subscribe of unsubscribe from i.e. MMM and ALV.
# @see https://developer.mailchimp.com/documentation/mailchimp/reference/lists/members

# For an initial setup all users should be updated using following function.

# Because I didn't want to wait for Mailchimp to perform my task this is build
# as an asynchronous task using redis. There are also other platform that can
# be configured in config/application.rb

# @param [member] member affected using this job
# @param [interests] contains a number of interst ids listed in app.yaml, NIL will not change the interests
# @param [create_on_missing] create a new Mailchimp account using member.email
# @param [mailchimp_status] Mailchimp status for maillings
#
# Job used Redis/sidekiq
class MailchimpJob < ApplicationJob
  queue_as :default

  def perform(member, interests = Settings['mailchimp.interests'].values, create_on_missing = false, mailchimp_status = 'subscribed')

    if ENV['MAILCHIMP_DATACENTER'].blank?
      logger.fatal('Mailchimp not configured correctly') unless Rails.env.development?
      return
    end

    request = {
      email_address: member.email,
      status: mailchimp_status,

      merge_fields: {
        FIRSTNAME: member.first_name,
        LASTNAME: (infix.blank? ? member.last_name : "#{ member.infix } #{ member.last_name }"),
        STUDIES: member.studies.pluck(:code).join(' ')
      }
    }

    # set required create attribute and set interests from mailchimp.interests (MMM/ALV/..)
    request[:status_if_new] = mailchimp_status if create_on_missing
    request[:interests] = Settings['mailchimp.interests'].values.map { |i| { i => interests.include?(i) } }.reduce(&:merge) unless interests.nil?

    logger.debug request.inspect

    if create_on_missing
      RestClient.put(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(member.email.downcase) }",
        request.to_json,
        Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
        'User-Agent': 'constipated-koala'
      )

    else
      RestClient.patch(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(member.email.downcase) }",
        request.to_json,
        Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
        'User-Agent': 'constipated-koala'
      )
    end

    Rails.cache.write("members/#{ member.id }/mailchimp/interests", request[:interests], expires_in: 30.days) unless intersts.nil?

    tags = []
    tags.push('alumni') unless member.educations.any? { |s| ['active'].include? s.status }
    tags.push('gratie') if member.tags.any? { |t| ['merit', 'pardon'].include? t.name }

    RestClient.post(
      "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(member.email.downcase) }/tags",
      { tags: Settings['mailchimp.tags'].map { |i| { name: i, status: (tags.include?(i) ? 'active' : 'inactive') } } }.to_json,
      Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
      'User-Agent': 'constipated-koala'
    )
  rescue RestClient::BadRequest => error
    logger.debug JSON.parse(error.response.body)
    raise error
  rescue RestClient::NotFound => error
    logger.debug 'record not found'
    raise error
  end
end
