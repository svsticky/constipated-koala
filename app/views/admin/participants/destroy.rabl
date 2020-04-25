object @activity
attributes :paid_sum, :price_sum

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

node :magic_reservists do
  @reservists&.map do |participant|
    partial 'admin/participants/create', object: participant
  end
end
