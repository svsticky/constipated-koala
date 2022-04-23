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

      activities = member.unpaid_activities.map {|x| x.name}

      prices = member.unpaid_activities.map { |activity|
        member.participant_by_activity(activity).currency
      }

      total = prices.sum

      # Render the html version of the email
      html = render_to_string(locals: {
        name: member.first_name,
        activities: activities,
        prices: prices,
        total: total
      })

      # Render the plaintext version of the email
      text = render_to_string(
        template: 'mailings/payment_mailer/requestmail.text.haml',
        locals: {
          name: member.first_name,
          activities: activities,
          prices: prices,
          total: total
        }
      )

      return mail(member.email, nil, subject, html, text)
    end
  end
end
