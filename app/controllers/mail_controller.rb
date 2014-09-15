class MailController < ApplicationController
  respond_to :json
  
  def mail
    # Load activity
    @activity = Activity.find(params[:id])
  
    # Select the correct members and fill in de variables and emails
    @participants = @activity.participants.where(member.email: params[:recipients].split(',').reject{ |s| s.match(/<([^<>]+)>/).nil? }.map{ |s| s.match(/<([^<>]+)>/)[1] })
    @recipients = @participants.map{ |member| member.email }.join(', ')
    @variables = @participants.map{ |participant| "'#{participant.email}': { 'first_name': '#{participant.first_name}', 'infix': '#{participant.infix}', 'last_name': '#{participant.last_name}', 'activity': '#{@activity.name}', 'price': '#{participant.price}' }"}.join(', ')

    logger.debug ''    
    logger.debug @recipients
    logger.debug ''
    logger.debug "{#{@variables}}"
    
    @response = RestClient.post "https://api:#{ConstipatedKoala::Application.config.mailgun}@api.mailgun.net/v2/stickyutrecht.nl/messages",
      :from => 'Martijn Casteel <penningmeester@stickyutrecht.nl>',
      
      :to => @recipients,
      'recipient-variables' => "{#{@variables}}",
      
      :subject => params[:subject],
      'o:tag' => @activity.name,
      
      :text => params[:text]
#      :html => params[:html]
      
    render :json => @response
  end
end
