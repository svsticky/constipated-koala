# coding: utf-8

class Mailgun < ActionMailer::Base #Devise::Mailer
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers
  
  def confirmation_instructions(record, token, opts={})
    #todo aanpasbaar maken
    @email = record.unconfirmed_email ||= record.email
    @text = 'Hoi %recipient.first_name%,\r\n\r\n Bevestig je email voor Constipated Koala door naar %recipient.link% te gaan.\r\n\r\n Met vriendeijke groet'
    return mail(@email, "\"#{@email}\" : { \"link\": \"#{confirmation_url(record, confirmation_token: token)}\", \"first_name\" : \"lid\"}", 'noreply@stickyutrecht.nl', 'reset password', 'Sticky account activeren', nil, @text)
  end

  def reset_password_instructions(record, token, opts={})
    #todo aanpasbaar maken
    @text = 'Hoi %recipient.first_name%,\r\n\r\n Er is een nieuw wachtwoord aangevraagd voor Constipated Koala.\r\nGa naar %recipient.link% om een nieuw wachtwoord in te stellen. \r\n\r\n Met vriendeijke groet'
    return mail(record.email, "\"#{record.email}\" : { \"link\": \"#{edit_password_url(record, reset_password_token: token)}\", \"first_name\" : \"lid\"}", 'noreply@stickyutrecht.nl', 'password reset', 'Sticky wachtwoord opnieuw instellen', nil, @text)
  end

  def participant_information(recipients, activity, sender, subject, html, text)  
 
    # Select the correct members
    @participants = activity.participants.joins(:member).where('members.email' => recipients.split(',').reject{ |s| s.match(/<([^<>]+)>/).nil? }.map{ |s| s.match(/<([^<>]+)>/)[1] })
    @recipients = @participants.joins(:member).map{ |participant| participant.member.email }.join(', ')
    
    @variables = @participants.map{ |participant| "\"#{participant.member.email}\" : { \"name\": \"#{participant.member.name}\", \"first_name\": \"#{participant.member.first_name}\", \"activity\": \"#{activity.name.downcase}\", \"price\": \"#{ActionController::Base.helpers.number_to_currency(participant.currency, :unit => '€')}\" }"}.join(', ')
    
    return mail(@recipients, @variables, sender, activity.name, subject, nil, text)
  end
  
  private
  def mail(recipients, variables, sender, tag, subject, html, text)
    @response = RestClient.post "https://api:#{ConstipatedKoala::Application.config.mailgun}@api.mailgun.net/v2/stickyutrecht.nl/messages",
      :from => sender,
      
      :to => recipients,
      'recipient-variables' => "{#{variables.to_s}}",
      
      :subject => subject,
      'o:tag' => tag,
      
      :html => html,
      :text => text
      
    return @response
  end
end