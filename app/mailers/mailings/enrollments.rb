module Mailings
  class Enrollments < Mailer

    def enrolled(participant)
      return if ENV['MAILGUN_TOKEN'].blank?

      member = participant.member
      activity = participant.activity
      url = url_for :controller => "users/enrollments", :action => "show", :id => activity.id

      starts_at = I18n.l activity.start_date, format: :day_month
      if activity.start_time
        starts_at += ", om #{I18n.l activity.start_time, format: :short}"
      end

      price = activity.price
      if price > 0
        price = "kost €#{'%.02f' % price}"
      else
        price = "is gratis :)"
      end

      subject = "Studievereniging Sticky | Je bent ingeschreven voor #{activity.name}"

      html = render_to_string( :layout => "mailings", :locals => {
        name: member.first_name,
        activity: activity,
        starts_at: starts_at,
        price: price,
        url: url,
        unenroll_date: activity.unenroll_date,
        subject: subject
      })

      text = <<-EOS
        Hoi #{member.first_name},

        Geweldig nieuws! Er is een plaats vrijgekomen voor #{activity.name}. Hiervoor ben je automatisch ingeschreven vanaf de reservelijst.

        De activiteit begint op #{starts_at} en #{price}. Tot dan!

        Je kunt je tot #{activity.unenroll_date} uitschrijven voor deze activiteit. Dit kun je doen op de pagina van de activiteit.
        Naar de activiteit: #(url)

        Met vriendelijke groet,

        Studievereniging Sticky
      EOS

      return mail(member.email, nil, subject, html, text)
    end
  end
end