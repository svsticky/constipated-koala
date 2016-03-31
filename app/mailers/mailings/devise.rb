# coding: utf-8

module Mailings
  class Devise < Mailer
    include ::Devise::Controllers::UrlHelpers

    def confirmation_instructions(record, token, opts={})
      puts confirmation_url(record, confirmation_token: token) if Rails.env.development?

      html = render_to_string :locals => {
        name: record.credentials.name,
        confirmation_url: confirmation_url(record, confirmation_token: token)
      }

      text = "Hoi #{record.credentials.name},\r\n\r\n Bevestig je email voor je account bij studievereniging sticky door naar #{confirmation_url(record, confirmation_token: token)} te gaan.\r\n\r\n Met vriendelijke groet"

      return mail(record.unconfirmed_email ||= record.email, nil, 'Sticky account activeren', html, text)
    end


    def reset_password_instructions(record, token, opts={})
      puts edit_password_url(record, reset_password_token: token) if Rails.env.development?

      html = render_to_string :locals => {
        name: record.credentials.name,
        reset_url: edit_password_url(record, reset_password_token: token)
      }

      text = "Hoi #{record.credentials.name},\r\n\r\n Er is een nieuw wachtwoord aangevraagd voor studievereniging sticky of je hebt geprobeerd een nieuwe account aan te maken.\nGa naar #{edit_password_url(record, reset_password_token: token)} om een nieuw wachtwoord in te stellen of negeer deze e-mail als je het wachtwoord nog weet. \r\n\r\n Met vriendelijke groet"

      return mail(record.email, nil, 'Sticky wachtwoord opnieuw instellen', html)
    end
  end
end
