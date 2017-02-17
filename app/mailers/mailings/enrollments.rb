module Mailings
  class Enrollments < Mailer

    def enrolled(participant)
      return if ENV['MAILGUN_TOKEN'].blank?

      member = participant.member
      activity = participant.activity

      starts_at = I18n.l activity.start_date, format: :day_month
      if activity.start_time
        starts_at += ", om #{I18n.l activity.start_time, format: :short}"
      end

      subject = "Studievereniging Sticky | Je bent ingeschreven voor #{activity.name}"

      html = render_to_string( :layout => "mailings", :locals => {
        name: member.name,
        activity: activity,
        starts_at: starts_at,
        subject: subject
      })


      text = <<-EOS
        Hoi #{member.first_name},

        Geweldig nieuws! Je bent van de reservelijst ingeschreven voor #{activity.name}!

        Je hoeft nu verder niets meer te doen, behalve natuurlijk op tijd zijn. De activiteit begint op #{starts_at}, tot dan!

        Met vriendelijke groet,

        Studievereniging Sticky
      EOS

      return mail(member.email, nil, subject, html, text)
    end
  end
end
