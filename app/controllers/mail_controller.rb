# coding: utf-8

class MailController < ApplicationController
  respond_to :json
  
  def mail
    # Load activity
    @activity = Activity.find(params[:id])
  
    # Select the correct members and fill in de variables and emails
    @participants = @activity.participants.joins(:member).where('members.email' => params[:recipients].split(',').reject{ |s| s.match(/<([^<>]+)>/).nil? }.map{ |s| s.match(/<([^<>]+)>/)[1] })
    @recipients = @participants.joins(:member).map{ |participant| participant.member.email }.join(', ')
    @variables = @participants.map{ |participant| "\"#{participant.member.email}\" : { \"name\": \"#{participant.member.name}\", \"first_name\": \"#{participant.member.first_name}\", \"activity\": \"#{@activity.name.downcase}\", \"price\": \"#{ActionController::Base.helpers.number_to_currency(participant.currency, :unit => '€')}\" }"}.join(', ')

    @response = RestClient.post "https://api:#{ConstipatedKoala::Application.config.mailgun}@api.mailgun.net/v2/stickyutrecht.nl/messages",
      :from => 'Martijn Casteel <penningmeester@stickyutrecht.nl>',
      
      :to => @recipients,
      'recipient-variables' => "{#{@variables.to_s}}",
      
      :subject => params[:subject],
      'o:tag' => @activity.name,
      
#      :html => params[:html],
      :text => params[:text]
      
    render :json => @response
  end
end
