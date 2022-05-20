#:nodoc:
module Mailings
  # Used for sending an mail to members that should consent or update their studystatus
  class Status < ApplicationMailer
    def consent(members)
      variables = {}

      members.each do |id, first_name, infix, last_name, email|
        variables[email] = {
          first_name: first_name,
          name: (infix.blank? ? "#{ first_name } #{ last_name }" : "#{ first_name } #{ infix } #{ last_name }"),
          email: email,
          url: Rails.application.routes.url_helpers.status_url(token: Token.create(
            object_type: 'Member', object_id: id, intent: 'consent'
          ).token)
        }
      end

      html = render_to_string(layout: 'mailer', locals: { subject: I18n.t('mailings.membership') })

      text = <<~PLAINTEXT
        #{ I18n.t('mailings.greeting') } %recipient.first_name%,

        #{ I18n.t('mailings.gdpr.gdpr_instructions') }

        %recipient.url%

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      PLAINTEXT

      return mails(variables, nil, I18n.t('mailings.membership'), html, text)
    end

    # TODO: send export and say bye
    def destroy; end
  end
end
