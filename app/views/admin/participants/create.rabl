object @participant
attributes :id, :notes

child :member do
  attributes :id, :name, :email
end

child :activity do
  attributes :price, :fullness, :paid_sum, :price_sum
end
