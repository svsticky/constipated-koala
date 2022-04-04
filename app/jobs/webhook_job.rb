# The webhook job is responsible for sending update information to the
# subscribed URLS
class WebhookJob < ApplicationJob
  queue_as :default

  def perform(type, id)
    return if ENV['WEBHOOK_URLS'].blank?

    request = {
      type: type,
      id: id
    }

    ENV['WEBHOOK_URLS'].split(';').each { |url|
      begin
        RestClient.post(
          url,
          request.to_json,
          'User-Agent': 'constipated-koala'
        )
      rescue RestClient::ExceptionWithResponse => e
        logger.error("ERROR: WEBHOOK " + url + " RETURNED: " + e.to_s)
      end
    }
  end
end
