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

# @param [key] unique identifier used in mailchimp (last known email)
# @param [member] member affected using this job
# @param [interests] contains a number of interst ids listed in app.yaml, NIL will not change the interests
# @param [mailchimp_status] Mailchimp status for maillings
class MailchimpJob < ApplicationJob
  queue_as :default

  def perform(key, member, interests = Rails.configuration.mailchimp_interests.values, mailchimp_status = 'subscribed')
    return if ENV['MAILCHIMP_DATACENTER'].blank?

    request = {
      email_address: member.email,
      status: mailchimp_status,

      merge_fields: {
        FIRSTNAME: member.first_name,
        LASTNAME: (member.infix.blank? ? member.last_name : "#{ member.infix } #{ member.last_name }")
      }
    }

    # just update existing users if lists are not given
    request[:status_if_new] = mailchimp_status unless interests.nil?

    # set interests from mailchimp_interests (MMM/ALV/..) if interests not nil
    unless interests.nil?
      request[:interests] = (Rails.configuration.mailchimp_interests.values +
      Rails.configuration.mailchimp_interests_alumni.values).map do |i|
        { i => interests.include?(i) }
      end.reduce(&:merge)
    end

    logger.debug(request.inspect)

    RestClient.put(
      "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(key.downcase) }",
      request.to_json,
      Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
      'User-Agent': 'constipated-koala'
    )

    # archive user without interests, update member information and tags if interests is nil
    # this needs to be done *after* updating interests, otherwise the archived
    # user still has interests.
    if !interests.nil? && interests.empty?
      RestClient.delete(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(key.downcase) }",
        Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
        'User-Agent': 'constipated-koala'
      )

      return
    end

    unless interests.nil?
      Rails.cache.write("members/#{ member.id }/mailchimp/interests", request[:interests],
                        expires_in: 30.days)
    end

    tags = []
    tags.push('alumni') unless member.educations.any? { |s| ['active'].include?(s.status) }
    tags.push('gratie') if member.tags.any? { |t| ['merit', 'pardon'].include?(t.name) }

    RestClient.post(
      "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(key.downcase) }/tags",
      { tags: Rails.configuration.mailchimp_tags.map do |i|
                { name: i, status: (tags.include?(i) ? 'active' : 'inactive') }
              end }.to_json,
      Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }",
      'User-Agent': 'constipated-koala'
    )
  rescue RestClient::BadRequest => e
    logger.debug(JSON.parse(e.response.body))
  rescue RestClient::NotFound
    logger.debug('record not found')
  end
end
