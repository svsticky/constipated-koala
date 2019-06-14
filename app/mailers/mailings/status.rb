#:nodoc:
module Mailings
  # Used for sending an mail to members that should consent or update their studystatus
  class Status < ApplicationMailer
    def consent(members)
      variables = {}

      members.each do |id, first_name, infix, last_name, email|
        variables[email] = {
          :first_name => first_name,
          :name => (infix.blank? ? "#{ first_name } #{ last_name }" : "#{ first_name } #{ infix } #{ last_name }"),
          :email => email,
          :url => Rails.application.routes.url_helpers.status_url(:token => Token.create(:object_type => 'Member', :object_id => id, :intent => 'consent').token)
        }
      end

      puts variables.inspect

      html = render_to_string :layout => 'mailer', :locals => { subject: 'Lidmaatschap Studievereniging Sticky' }

      text = <<~PLAINTEXT
        Hoi %recipient.first_name%,

        #{ I18n.t('mailings.gdpr.gdpr_instructions') }

        %recipient.url%

        Met vriendelijke groet,

        Het bestuur
      PLAINTEXT

      return mails(variables, nil, 'Lidmaatschap Studievereniging Sticky', html, text)
    end

    # TODO: send export and say bye
    def destroy; end
  end
end
