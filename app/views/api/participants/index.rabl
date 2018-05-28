collection @participants

if params['activity_id'].present?
  child :member do
    attributes :id, :first_name, :infix, :last_name
  end

else
  child :activity do
    attributes :id, :name, :start_date, :end_date
  end
end

attributes :paid, :created_at
attribute :currency => :price
