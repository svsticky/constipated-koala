collection @activities

attribute :id, :name, :location, :price, :show_on_website, :description

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

node :poster do |a|
    full_url_for a.poster_representation
end

node :thumbnail do |a|
    full_url_for a.thumbnail_representation
end
