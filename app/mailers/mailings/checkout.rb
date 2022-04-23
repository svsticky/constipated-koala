#:nodoc:
module Mailings
  #:nodoc:
  class Checkout < ApplicationMailer
    def confirmation_instructions(card, confirmation_url)
      Rails.logger.debug confirmation_url if Rails.env.development?

      subject_name = "#{ I18n.t('association_name') } | #{ I18n.t('mailings.checkout.subject') }"

      html = render_to_string(layout: 'mailer', locals: {
                                name: card.member.first_name,
                                confirmation_url: confirmation_url,
                                subject: subject_name
                              })

      text = <<~PLAINTEXT
        #{ I18n.t('mailings.greeting') } #{ card.member.first_name },

        #{ I18n.t('mailings.checkout.confirm_card_link', confirm_url: confirmation_url) }

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      PLAINTEXT

      return mail(card.member.email, nil, subject_name, html, text)
    end
  end
end
