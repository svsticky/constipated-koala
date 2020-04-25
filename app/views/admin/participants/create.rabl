object @participant
attributes :id, :notes

child :member do
  attributes :id, :name, :email
end

child :activity do
  attributes :price, :paid_sum, :price_sum

  node :fullness do |activity|
    if activity.participant_limit
      "#{ activity.attendees.count }/#{ activity.participant_limit }"
    else
      activity.attendees.count
    end
  end

  node :reservist_count do |activity|
    activity.reservists.count
  end
end
