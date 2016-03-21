collection @activities

attributes :name, :start_date, :end_date

if Authorization._client.include?('activities-read')
  attributes :id, :description, :price
end

node :poster do
  |activity| activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end
