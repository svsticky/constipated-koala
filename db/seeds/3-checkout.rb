# Create checkout cards will automatically create balances
puts '-- Creating checkout balances and cards'
Member.all.sample(30).each do |member|
  Faker::Number.between(1, 2).times do
    CheckoutCard.create(
      uuid:                Faker::Number.hexadecimal(8),
      active:              Faker::Boolean.boolean(0.9),
      member_id:           member.id
    )
  end
end

puts '-- Creating products'
5.times do
  # Create a few food products
  CheckoutProduct.create!(
    name:                  Faker::Food.unique.dish,
    category:              Faker::Number.between(2, 4),
    price:                 Faker::Number.between(0.50, 4.0),
    skip_image_validation: true
  )
end

2.times do
  # Create a few alcoholic products
  CheckoutProduct.create(
    name:                  Faker::Beer.name,
    category:              5,
    price:                 Faker::Number.between(1.0, 3.0),
    skip_image_validation: true
  )
end

puts '-- Giving away free money'
CheckoutCard.all.each do |card|
  CheckoutTransaction.create(
    checkout_card_id:            card.id,
    price:                       9.00,
    payment_method:              %w[Gepind Contant].sample,
    created_at:                  Faker::Time.between(Time.now - 1.days, card.member.join_date)
  )
end

puts '-- Creating checkout transactions'
CheckoutCard.all.each do |card|
  Faker::Number.between(0, 10).times do
    checkout_products = CheckoutProduct.all
    checkout_products.reject(&:liquor?) if card.member.underage?

    CheckoutTransaction.create(
      checkout_card_id:            card.id,
      items:                       checkout_products.sample(Faker::Number.between(1, 3)).map(&:id),
      payment_method:              'Verkoop',
      created_at:                  Faker::Time.between(Time.now, card.member.join_date)
    )
  end
end
