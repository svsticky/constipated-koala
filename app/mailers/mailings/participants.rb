# coding: utf-8

module Mailings
  class Participants < Mailer

    def inform( activity, recipients, sender, subject, html, text = nil )
      participants = activity.participants.joins( :member ).where( 'members.email' => recipients )

      # hash for mailgun with recipient-variables
      variables = Hash.new

      participants.each do |participant|
        variables[ participant.member.email ] = {
          :name => participant.member.name,
          :first_name => participant.member.first_name,

          :activity => participant.activity.name,
          :price => ActionController::Base.helpers.number_to_currency( participant.currency, :unit => '€' )
        }
      end

      # NOTE view is rendered in form for editing
      html = render_to_string :text => html, :layout => 'mailings'
      return mails( variables, sender, subject, html )
    end
  end
end
