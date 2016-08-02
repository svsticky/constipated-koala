# coding: utf-8

module Mailings
  class Checkout < Mailer

    def confirmation_instructions (card, confirmation_url)
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string( :layout => "mailings", :locals => {
        name: card.member.first_name,
        confirmation_url: confirmation_url,
        subject: 'Studievereniging Sticky | kaart bevestigen'
      })

      text = <<-EOS
        Hoi #{card.member.first_name},

        Bevestig je kaart voor je account bij studievereniging sticky door naar #{confirmation_url} te gaan.

        Met vriendelijke groet
      EOS

      return mail(card.member.unconfirmed_email ||= card.member.email, nil, 'Sticky kaart activeren', html, text)
    end
  end
end