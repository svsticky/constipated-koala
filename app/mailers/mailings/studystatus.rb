#:nodoc:
module Mailings
  # Used for sending an mail to members that should consent
  class Studystatus < ApplicationMailer
    def update(members)
      return if ENV['MAILGUN_TOKEN'].blank?

      recipients = members.map do |member|
      end

      html = render_to_string :inline => html, :layout => 'mailer', :locals => { subject: 'Lidmaatschap Studievereniging Sticky' }

      text = <<~PLAINTEXT
        Hoi %recipient.first_name%,

        Op het moment sta je bij Studievereniging ingeschreven.

        Met vriendelijke groet,

        Het bestuur
      PLAINTEXT

      return mails(recipients, nil, '', html, text)
    end
  end
end
