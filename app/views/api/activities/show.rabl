object @activity
attributes :id, :name, :description_nl, :description_en, :price, :location, :show_on_website

node :start_date do |activity|
  if activity.start_time.nil?
    activity.start_date
  else
    d = activity.start_date
    t = activity.start_time
    Time.new(d.year, d.month, d.day, t.hour, t.min, 0).iso8601
  end
end

node :end_date do |activity|
  if activity.end_time.nil?
    activity.end_date
  else
    d = activity.end_date
    t = activity.end_time
    Time.new(d.year, d.month, d.day, t.hour, t.min, 0).iso8601
  end
end

node :unenroll_date do |activity|
  activity.unenroll_date&.iso8601
end

node :attendees do |activity|
  activity.participant_filter(activity.ordered_attendees)
end

node :reservists do |activity|
  activity.participant_filter(activity.ordered_reservists)
end

glue :group do
  attribute :name => :group
end

node :enrollable do |activity|
  !activity.participant_limit.nil? && activity.attendees.count < activity.participant_limit
end

node :location do |activity|
  activity.location unless activity.location.nil?
end

node :poster do |a|
  full_url_for a.poster_representation
end

node :thumbnail do |a|
  full_url_for a.thumbnail_representation
end
