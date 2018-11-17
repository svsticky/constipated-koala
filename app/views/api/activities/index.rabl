collection @activities

attribute :id, :name, :location, :price

node :participant_counter, &:fullness

node :start_date do |activity|
  if activity.start_time.nil?
    activity.start_date
  else
    d = activity.start_date
    t = activity.start_time
    Time.zone.local(d.year, d.month, d.day, t.hour, t.min, 0).iso8601
  end
end

node :end_date do |activity|
  if activity.end_time.nil?
    activity.end_date
  else
    d = activity.end_date
    t = activity.end_time
    Time.zone.local(d.year, d.month, d.day, t.hour, t.min, 0).iso8601
  end
end

attributes :description if Authorization._client.include?('activity-read')

node :poster do |activity|
  "#{ ENV['KOALA_DOMAIN'] }#{ url_for activity.poster.representation(resize: 'x1080')}" if activity.poster.attached?
end
