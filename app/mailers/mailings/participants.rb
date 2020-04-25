#:nodoc:
module Mailings
  #:nodoc:
  class Participants < ApplicationMailer
    def inform(activity, recipients, sender, subject, html, text = nil)
      participants = activity.participants.joins(:member).where('members.email' => recipients)

      # hash for mailgun with recipient-variables
      variables = {}

      participants.each do |participant|
        variables[participant.member.email] = {
          :name => participant.member.name,

          :first_name => participant.member.first_name,
          :price => ActionController::Base.helpers.number_to_currency(participant.currency, :unit => '€')
        }
      end

      view = render_to_string :inline => html, :layout => 'mailer', :locals => { subject: subject }
      return mails(variables, sender, subject, view, text || strip_html(html.clone))
    end

    def enrolled(participant)
      return if ENV['MAILGUN_TOKEN'].blank?

      member = participant.member
      activity = participant.activity
      url = activity_url activity.id

      starts_at = I18n.l activity.start_date, format: :day_month
      starts_at += ", om #{ I18n.l activity.start_time, format: :short }" if activity.start_time

      price = activity.price
      price = if price > 0
                "kost €#{ format('%.02f', price) }" # rubocop:disable Style/FormatStringToken:
              else
                "is gratis"
              end

      subject = "Studievereniging Sticky | Je bent ingeschreven voor #{ activity.name }"

      html = render_to_string(:layout => 'mailer', :locals => {
                                name: member.first_name,
                                activity: activity,
                                starts_at: starts_at,
                                price: price,
                                url: url,
                                unenroll_date: activity.unenroll_date,
                                subject: subject
                              })

      text = <<~PLAINTEXT
        Hoi #{ member.first_name },

        Geweldig nieuws! Er is een plaats vrijgekomen voor #{ activity.name }. Hiervoor ben je automatisch ingeschreven vanaf de reservelijst.

        De activiteit begint op #{ starts_at } en #{ price }. Tot dan!

        Je kunt je tot #{ activity.unenroll_date } uitschrijven voor deze activiteit. Dit kun je doen op de pagina van de activiteit.
        Naar de activiteit: #{ url }

        Met vriendelijke groet,

        Het bestuur
      PLAINTEXT

      return mail(member.email, nil, subject, html, text)
    end
  end
end
