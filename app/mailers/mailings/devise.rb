module Mailings
  class Devise < ApplicationMailer
    include ::Devise::Controllers::UrlHelpers

    def confirmation_instructions(record, token, _opts = {})
      puts confirmation_url(record, confirmation_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        confirmation_url: confirmation_url(record, confirmation_token: token),
        subject: 'Studievereniging Sticky | account bevestigen'
      }

      text = <<~PLAINTEXT
        Hoi #{ record.credentials.name },

        Bevestig je email voor je account bij studievereniging sticky door naar #{ confirmation_url(record, confirmation_token: token) } te gaan.

        Met vriendelijke groet,
        Het bestuur
      PLAINTEXT

      return mail(record.unconfirmed_email ||= record.email, nil, 'Sticky account activeren', html, text)
    end

    def activation_instructions(record, token, _opts = {})
      url = new_member_confirmation_url(confirmation_token: token)
      puts url if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.first_name,
        activation_url: url,
        subject: 'Welkom bij Sticky! | account activeren'
      }

      text = <<~MARKDOWN
        Hoi #{ record.credentials.first_name },

        ## Welkom bij Sticky!
        Je ontvangt deze mail omdat je je hebt aangemeld voor onze machtig mooie studievereniging! Aan het eind van deze mail vind je de knop om je account in ons ledenportaal te activeren. Je kunt ook dit prachtige introductiepraatje overslaan en meteen naar beneden scrollen, dat zien we toch niet (of toch wel?).

        Bij Sticky kun je terecht voor alles wat jij als student Informatica, Informatiekunde of Gametechnologie nodig hebt! Zoals je wellicht al vernomen hebt, kun je altijd een gratis kop koffie en een koekje scoren in onze kamer (BBG 2.81), of een ander(e) drankje/snack. In de kamer is ook altijd iemand van het bestuur aanwezig om al jouw vragen te beantwoorden. Naast deze plek om te chillen tijdens pauzes of tussen de colleges door, organiseren we ook nog eens enorm veel woestgave activiteiten! Deze activiteiten zijn altijd in lijn met één van de drie pijlers van Sticky: onderwijs, bedrijfsleven en gezelligheid.

        Altijd op de hoogte blijven van deze activiteiten? Word lid van de [Sticky-leden Facebookgroep][1] en like [onze pagina][2]!
        Daarnaast vind je alle informatie die je ooit had kunnen wensen op onze website: [svsticky.nl][3].

        ## Onderwijs
        Wij organiseren hulpmiddagen, workshops en informatiebijeenkomsten om jou te ondersteunen bij je studie. Ook is de Commissaris Onderwijs jouw aanspreekpunt voor alles wat met het onderwijs en de kwaliteit daarvan te maken heeft. Bij ons kun je je studieboeken gemakkelijk kopen en thuis later bezorgen via [svsticky.nl/boeken][4]!

        ## Bedrijfsleven
        Om jou een zo goed mogelijk beeld te geven van al die verschillende bedrijven waar jij later aan de slag kunt, organiseren wij in samenwerking met deze bedrijven verschillende lezingen, workshops, inhousedagen en borrels. Deze activiteiten bieden naast informatie over het bedrijf in kwestie, ook nog eens een mooie gelegenheid om eens iets extra’s/compleet nieuws te leren. Op zoek naar een studiegerelateerde (bij)baan? Deze vind je via [svsticky.nl/partners/vacatures][5]!

        ## Gezelligheid
        Naast alle bovenstaande studie- en carrièregerelateerde activiteiten, organiseren we ook veel simpelweg gezellige activiteiten. Daarnaast is er wekelijks een gratis borrel!

        ## En nu?
        Nieuwsgierig naar welke activiteiten we binnenkort organiseren? Meer informatie vind je in ons ledenportaal en je kunt je daar ook meteen inschrijven! Daarnaast kun je in dit ledenportaal ook je gegevens aanpassen en je tegoed voor snacks en drinken opwaarderen.

        Activeer je account voor ons ledenbeheersysteem door naar #{ url } te gaan.

        Tot snel!
        Het bestuur

        [1]: https://www.facebook.com/groups/814759978565158
        [2]: https://www.facebook.com/stickyutrecht
        [3]: https://svsticky.nl
        [4]: https://svsticky.nl/boeken
        [5]: https://svsticky.nl/partners/vacatures
      MARKDOWN

      return mail(record.email, nil, 'Welkom bij Sticky | account activeren', html, text)
    end

    def reset_password_instructions(record, token, _opts = {})
      puts edit_password_url(record, reset_password_token: token) if Rails.env.development?
      return if ENV['MAILGUN_TOKEN'].blank?

      html = render_to_string :locals => {
        name: record.credentials.name,
        reset_url: edit_password_url(record, reset_password_token: token),
        subject: 'Studievereniging Sticky | wachtwoord herstellen'
      }

      text = <<~PLAINTEXT
        Hoi #{ record.credentials.name },

        Er is een nieuw wachtwoord aangevraagd voor je Sticky account, of je hebt geprobeerd een nieuwe account aan te maken.
        Ga naar #{ edit_password_url(record, reset_password_token: token) } om een nieuw wachtwoord in te stellen of negeer deze e-mail als je je huidige wachtwoord wil behouden.

        Met vriendelijke groet,
        Het bestuur
      PLAINTEXT

      return mail(record.email, nil, 'Sticky wachtwoord opnieuw instellen', html, text)
    end
  end
end
