collection @products

attributes :id, :name, :category, :price

node :image do |product|
  url_for product.url
end
