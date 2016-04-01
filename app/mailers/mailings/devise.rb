# coding: utf-8

module Mailings
  class Devise < Mailer
    include ::Devise::Controllers::UrlHelpers

    def confirmation_instructions(record, token, opts={})
      puts confirmation_url(record, confirmation_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        confirmation_url: confirmation_url(record, confirmation_token: token)
      }

      text = <<-EOS
        Hoi #{record.credentials.name},

        Bevestig je email voor je account bij studievereniging sticky door naar #{confirmation_url(record, confirmation_token: token)} te gaan.

        Met vriendelijke groet
      EOS

      return mail(record.unconfirmed_email ||= record.email, nil, 'Sticky account activeren', html, text)
    end


    def reset_password_instructions(record, token, opts={})
      puts edit_password_url(record, reset_password_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        reset_url: edit_password_url(record, reset_password_token: token)
      }

      text = <<-EOS
        Hoi #{record.credentials.name},

        Er is een nieuw wachtwoord aangevraagd voor je Sticky account, of je hebt geprobeerd een nieuwe account aan te maken.
        Ga naar #{edit_password_url(record, reset_password_token: token)} om een nieuw wachtwoord in te stellen of negeer deze e-mail als je je huidige wachtwoord wil behouden.

        Met vriendelijke groet
      EOS

      return mail(record.email, nil, 'Sticky wachtwoord opnieuw instellen', html)
    end
  end
end
