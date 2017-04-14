class Admin::PaymentsController < ApplicationController

  def index
    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
    @last_impressions = Activity.debtors.map { |activity|
      impression = Impression.where(impressionable_type: Activity).where(impressionable_id: activity.id).where(message: "mail").where('created_at > ?', activity.start).last

      unless impression.nil?
        days = Integer(Date.today - impression.created_at.to_date)
      else
        days = "-"
      end
      [activity, days]
    }

    # Get members of which the activities have been mailed 4 times, but haven't paid yet
    @late_activities = Activity.debtors.select { |activity| activity.impressionist_count(message: "mail", start_date: activity.start) >= 4 }
    @late_payments = @late_activities.map{ |activity|
      activity.participants.select{ |participant| participant.paid == false and participant.price != 0 }.map{ |p| p.member}
    }.flatten.uniq
  end
end
