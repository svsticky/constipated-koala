collection @products

attributes :id, :name, :category, :price

node :image do |product|
  "#{ENV['KOALA_DOMAIN']}#{url_for product.url}"
end
