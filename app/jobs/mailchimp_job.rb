# Mailchimp is used to send mailings to members and alumni, for this reason
# this functionality requires two Mailchimp lists. One list for members and
# one for alumni. These lists should be created manually.

# To distinct students from eachother we will add some custom meta data such
# as studies. Furthermore we can create groups where the member itself can
# subscribe of unsubscribe from i.e. MMM and ALV.

# For an initial setup all users should be updated using following function.

# Because I didn't want to wait for Mailchimp to perform my task this is build
# as an asynchronous task using redis. There are also other platform that can
# be configured in config/application.rb

# rubocop:disable Style/BracesAroundHashParameters
class MailchimpJob < ApplicationJob
  queue_as :default

  def perform(member, interests = Settings['mailchimp.interests'].values, create_on_missing = false, mailchimp_status = 'subscribed')
    request = {
      email_address: member.email,
      status: mailchimp_status,

      merge_fields: {
        FIRSTNAME: member.first_name,
        STUDIES: member.studies.pluck(:code).join(' ')
      }
    }

    # set required create attribute and set interests from mailchimp.interests (MMM/ALV/..)
    request[:status_if_new] = mailchimp_status if create_on_missing
    request[:interests] = Settings['mailchimp.interests'].values.map { |i| { i => interests.include?(i) } }.reduce(&:merge)

    if create_on_missing
      RestClient.put(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(member.email.downcase) }",
        request.to_json,
        { Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }", 'User-Agent': 'constipated-koala' }
      )

    else
      RestClient.patch(
        "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(member.email.downcase) }",
        request.to_json,
        { Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }", 'User-Agent': 'constipated-koala' }
      )
    end

    Rails.cache.write("members/#{ member.id }/mailchimp/interests", request[:interests]) # TODO: check of dit werkt

    tags = []
    tags.push('alumni') unless member.educations.any? { |s| ['active'].include? s.status }
    tags.push('gratie') if member.tags.any? { |t| ['merit', 'pardon'].include? t.name }

    RestClient.post(
      "https://#{ ENV['MAILCHIMP_DATACENTER'] }.api.mailchimp.com/3.0/lists/#{ ENV['MAILCHIMP_LIST_ID'] }/members/#{ Digest::MD5.hexdigest(member.email.downcase) }/tags",
      { tags: Settings['mailchimp.tags'].map { |i| { name: i, status: (tags.include?(i) ? 'active' : 'inactive') } } }.to_json,
      { Authorization: "mailchimp #{ ENV['MAILCHIMP_TOKEN'] }", 'User-Agent': 'constipated-koala' }
    )

    Rails.cache.write("members/#{ member.id }/mailchimp/tags", tags)
  rescue RestClient::BadRequest => error
    logger.debug JSON.parse(error.response.body)
    raise error
  rescue RestClient::NotFound => error
    logger.debug 'record not found'
    raise error
  end

  # rubocop:enable Style/BracesAroundHashParameters
end
