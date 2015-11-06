collection @activities

attributes :id, :name, :description, :start_date, :end_date, :price
node :poster do
  |activity| activity.poster.url(:medium) unless activity.poster_updated_at.nil?
end
