collection @activities

attributes :name, :start_date, :end_date

node :start_time do |activity|
  activity.start_time.strftime('%H:%M') unless activity.start_time.nil?
end

node :end_time do |activity|
  activity.end_time.strftime('%H:%M') unless activity.end_time.nil?
end

if Authorization._client.include?('activities-read')
  attributes :id, :description, :price
end

node :poster do
  |activity| activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end
