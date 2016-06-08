collection @activities

attribute :name

node :start_date do |activity|
  if activity.start_time.nil?
    activity.start_date
  else
    d = activity.start_date
    t = activity.start_time
    DateTime.new(d.year, d.month, d.day, t.hour, t.min, 0)
  end
end

node :end_date do |activity|
  if activity.end_time.nil?
    activity.end_date
  else
    d = activity.end_date
	t = activity.end_time
	DateTime.new(d.year, d.month, d.day, t.hour, t.min, 0)
  end
end

if Authorization._client.include?('activities-read')
  attributes :id, :description, :price
end

node :poster do
  |activity| activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end
