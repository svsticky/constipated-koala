class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@svsticky.nl'
  layout 'mailer'

  def strip_html(text)
    # change line brakes and paragraphs
    text.gsub!(/<(?:br\/?|\/p)>/, "\r\n")

    # reformat url's
    text.gsub!(/<a\s+(?:[^>]*?\s+)?href=(\"[^"]*\"|'[^']*')(?:[^>]*?\s+)?\s*\/?>(?:.+<\/a>)/, '\1')

    # remove all other tags
    text.gsub!(/<\/?\w+\/?>/, '')

    # remove double spaces
    text.squeeze!(' ')

    # remove double line brakes
    text.gsub!(/[\r\n]{2,}/, "\r\n")

    return text
  end

  private

  def mail(recipient, sender, subject, html, text)
    raise ArgumentError if html.blank? && text.blank?

    return RestClient.post "https://api:#{ ENV['MAILGUN_TOKEN'] }@api.mailgun.net/v3/#{ ENV['MAILGUN_DOMAIN'] }/messages",
                           :from => sender ||= ::Devise.mailer_sender,
                           :to => recipient,

                           :subject => subject,
                           :html => html.to_str,
                           :text => text,
                           'o:testmode' => Rails.env == 'development' ? "true" : "false"
  end

  def mails(variables, sender, subject, html, text)
    raise ArgumentError if html.blank? && text.blank? || variables.blank?

    return RestClient.post "https://api:#{ ENV['MAILGUN_TOKEN'] }@api.mailgun.net/v3/#{ ENV['MAILGUN_DOMAIN'] }/messages",
                           :from => sender ||= ::Devise.mailer_sender,
                           :to => variables.map { |email, item| "#{ item['name'] } <#{ email }>" },

                           'recipient-variables' => variables.to_json,

                           :subject => subject,
                           :html => html.to_str,
                           :text => text,
                           'o:testmode' => Rails.env == 'development' ? "true" : "false"
  end
end
