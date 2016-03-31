# coding: utf-8

module Mailings
  class Mailer < ActionMailer::Base
    layout 'mailings'

    private
    def mail( recipient, sender, subject, html, text = nil )
      raise ArgumentError if html.blank? && text.blank?

      return RestClient.post "https://api:#{ENV['MAILGUN_TOKEN']}@api.mailgun.net/v3/svsticky.nl/messages",
        :from => sender ||= ::Devise.mailer_sender,
        :to => recipient,

        :subject => subject,
        :html => html.to_str,
        :text => text
    end

    def mails( variables, sender, subject, html, text = nil )
      raise ArgumentError if html.blank? && text.blank? || variables.blank?

      return RestClient.post "https://api:#{ENV['MAILGUN_TOKEN']}@api.mailgun.net/v3/svsticky.nl/messages",
        :from => sender ||= ::Devise.mailer_sender,
        :to => variables.map{ | email, item | "#{ item['name'] } <#{ email }>" },

        'recipient-variables' => variables.to_json,

        :subject => subject,
        :html => html.to_str,
        :text => text
    end
  end
end
