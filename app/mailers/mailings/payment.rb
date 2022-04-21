module Mailings
  class Payment < ApplicationMailer
    def requestmail(member)
      # return if ENV['MAILGUN_TOKEN'].blank? # TODO is this a good plan?
      I18n.locale = member.language

      email = member.email
      first_name = member.first_name,

      subject = I18n.t('mailings.payment.subject')

      total = 0

      activities = ""
      member.unpaid_activities.each do |activity|
        participant = member.participant_by_activity(activity)
        activities += "#{activity.name} (#{ActionController::Base.helpers.number_to_currency(participant.currency, unit: '€')})"
        total += activity.price
      end

      puts member

      html = render_to_string(locals: {
        name: member.first_name,
        activities: activities,
        total: total,
      })

      text = <<~TEXT
        #{I18n.t('mailings.greeting')} #{member.first_name}
    
        #{I18n.t('mailings.payment.open_activities')}
        #{activities}
    
        #{I18n.t('mailings.payment.total_of', amount: total)}
    
        #{I18n.t('mailings.best_regards')}
    
        #{I18n.t('mailings.signature')}
      TEXT

      return mail(member.email, nil, subject, html, text)
    end
  end
end
  