class WebhookJob < ApplicationJob
    queue_as :default
  
  def perform(type, id)
  
    request = {
      type: type,
      id: id
    }

    ENV['WEBHOOK_URLS'].split(';').each{|url|
      begin
        RestClient.post(
          url,
          request.to_json,
          'User-Agent': 'constipated-koala'
        )
      rescue RestClient::ExceptionWithResponse => err
        logger.error("ERROR: WEBHOOK " + url + " RETURNED: " + err.to_s)
      end
    }
  end
end