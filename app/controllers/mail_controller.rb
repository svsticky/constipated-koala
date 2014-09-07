class MailController < ApplicationController
  respond_to :json
  
  def send
    @response = RestClient.post "https://api:#{ConstipatedKoala::Application.config.mailgun}@api.mailgun.net/v2/stickyutrecht.nl/messages",
      :subject => 'test',
      'o:tag' => '',
      
      'h:Reply-To' => 'penningmeester@stickyutrecht.nl',
      
      :bcc => 'martijn.casteel@gmail.com',
      'recipients-variables' => '{ "martijn.casteel@gmail.com": { "name": "Martijn" }}',
      
      :text => '%name% testing'
    
    logger.debug @response
    respond_with @response
  end
end
