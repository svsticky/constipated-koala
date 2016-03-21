collection @products

attributes :id, :name, :category, :price

node :image do |product|
  product.url
end
