include Rails.application.routes.url_helpers

#:nodoc:
module Mailings

  # Used for sending an mail to members that should consent
  class GDPR < ApplicationMailer
    def consent(members)
      recipients = members.map do |id, first_name, email|
        {
          email => {
            'first_name': first_name,
            'email': email,
            'url': alumni_url(:token => Token.create(:object => Member.find_by_id(id), :intent => 'consent').token)
          }
        }
      end

      html = render_to_string :layout => 'mailer', :locals => { subject: 'Lidmaatschap Studievereniging Sticky' }

      text = <<~PLAINTEXT
        Hoi %recipient.first_name%,

        Op het moment sta je bij Studievereniging ingeschreven maar ben je volgens onze gegevens geen student meer aan de Universiteit Utrecht. Op dit moment hebben we je gegevens nog bewaard, maar het is aan jou om aan te geven of je dit ook wil. Zolang je ingeschreven staat kunnen we je benaderen voor alumni activiteiten. Volg onderstaande link om deze toestemming voor onbeperkte tijd te geven of voor een jaar, of verwijder je account en daarmee al je persoons gegevens bij Studievereniging Sticky.

        %recipient.url%

        Met vriendelijke groet,

        Het bestuur
      PLAINTEXT

      return mails(recipients, nil, '', html, text)
    end

    # TODO send export and say bye
    def destroy; end
  end
end
