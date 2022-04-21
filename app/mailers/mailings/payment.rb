#:nodoc:
module Mailings
  # The requestmail sends a payment request to the passed member. This payment
  # mail lists all open payments and the total amount that should be paid.
  # Only pass members that actually have open payments, otherwise the email will
  # ask for a payment of 0 euro.
  class PaymentMailer < ApplicationMailer
    def requestmail(member)
      # Send the email in the members' prefered language
      I18n.locale = member.language

      subject = I18n.t('mailings.payment.subject')

      # calculate the total amount and build a string containing the activities.
      total = 0
      activities = ""
      member.unpaid_activities.each do |activity|
        participant = member.participant_by_activity(activity)
        activities += "#{ activity.name } (#{
          ActionController::Base.helpers.number_to_currency(
            participant.currency,
            unit: '€'
          ) })"
        total += activity.price
      end

      # Render the html version of the email
      html = render_to_string(locals: {
                                name: member.first_name,
                                activities: activities,
                                total: total
                              })

      # Render the plaintext version of the email
      text = <<~TEXT
        #{ I18n.t('mailings.greeting') } #{ member.first_name }

        #{ I18n.t('mailings.payment.open_activities') }
        #{ activities }

        #{ I18n.t('mailings.payment.total_of', amount: total) }

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      TEXT

      return mail(member.email, nil, subject, html, text)
    end
  end
end
