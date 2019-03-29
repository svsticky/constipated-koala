object @activity
attributes :fullness, :paid_sum, :price_sum

node :reservist_count do |activity|
  activity.reservists.count
end

node :magic_reservists do |_activity|
  @reservists&.map do |participant|
    partial 'admin/participants/create', object: participant
  end
end
