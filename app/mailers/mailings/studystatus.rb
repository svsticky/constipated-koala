#:nodoc:
module Mailings
  # Used for sending an mail to members that should consent
  class Studystatus < ApplicationMailer
    def update(members)
      return if ENV['MAILGUN_TOKEN'].blank?

      recipients = members.map do |member|
        # TODO: This does not have a body, currently recipients will be emtpy
      end

      html = render_to_string inline: html, layout: 'mailer', locals: { subject: I18n.t('mailings.membership') }

      text = <<~PLAINTEXT
        #{ I18n.t('mailings.greeting') } %recipient.first_name%,

        #{ I18n.t('mailings.gdpr.enrolled') }

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      PLAINTEXT

      return mails(recipients, nil, '', html, text)
    end
  end
end
