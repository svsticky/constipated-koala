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
          name: participant.member.name,

          first_name: participant.member.first_name,
          price: ActionController::Base.helpers.number_to_currency(participant.currency, unit: '€')
        }
      end

      view = render_to_string(inline: html, layout: 'mailer', locals: { subject: subject })
      return mails(variables, sender, subject, view, text || strip_html(html.clone))
    end

    def enrolled(participant)
      member = participant.member
      activity = participant.activity
      url = activity_url(activity.id)

      starts_at = I18n.l(activity.start_date, format: :day_month)
      starts_at += ", #{ I18n.l(activity.start_time, format: :short) }" if activity.start_time

      price = activity.price
      price = if price > 0
                "#{ I18n.t('mailings.participants.enrolled.cost') } €#{ format('%.02f', price) }"
              else
                I18n.t('mailings.participants.enrolled.free')
              end

      subject = "#{ I18n.t('association_name') } | #{ I18n.t('mailings.participants.enrolled.subject', activity: activity.name) }"
      html = render_to_string(layout: 'mailer', locals: {
                                name: member.first_name,
                                activity: activity,
                                starts_at: starts_at,
                                price: price,
                                url: url,
                                unenroll_date: activity.unenroll_date,
                                subject: subject
                              })

      text = <<~HTML
        #{ I18n.t('mailings.greeting') } #{ member.first_name },

        #{ I18n.t('mailings.participants.enrolled.free_spot_html', activity_name: activity.name) }

        #{ I18n.t('mailings.participants.enrolled.activity_start_html', activity_start: starts_at, price: price) }

        #{ I18n.t('mailings.participants.enrolled.button_instructions_html', unenroll_date: activity.unenroll_date) }
        #{ I18n.t('mailings.participants.enrolled.to_the_activity') }: #{ url }

        #{ I18n.t('mailings.best_regards') }

        #{ I18n.t('mailings.signature') }
      HTML

      return mail(member.email, nil, subject, html, text)
    end
  end
end
