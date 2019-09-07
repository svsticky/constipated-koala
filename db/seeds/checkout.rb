require Rails.root.join('db', 'seeds', 'members.rb')

# Create checkout cards will automatically create balances
puts '-- Creating checkout balances and cards'
Member.all.sample(30).each do |member|
  Faker::Number.within(range: 0..2).times do
    CheckoutCard.create(
      uuid:                Faker::Number.hexadecimal(digits: 8),
      active:              Faker::Boolean.boolean(true_ratio: 0.9),
      member_id:           member.id
    )
  end
end

puts '-- Giving away free money'
CheckoutCard.all.each do |card|
  CheckoutTransaction.create(
    checkout_card_id:            card.id,
    price:                       9.00,
    payment_method:              %w[Gepind Contant].sample,
    created_at:                  Faker::Time.between(from: Time.now - 1.days, to: card.member.join_date)
  )
end

puts '-- Creating products'
5.times do
  # Create a few food products
  CheckoutProduct.create!(
    name:                  Faker::Food.unique.dish,
    category:              Faker::Number.within(range: 2..4),
    price:                 Faker::Number.between(from: 0.50, to: 4.0),
    skip_image_validation: true
  )
end

2.times do
  # Create a few alcoholic products
  CheckoutProduct.create(
    name:                  Faker::Beer.name,
    category:              5,
    price:                 Faker::Number.between(from: 1.0, to: 3.0),
    skip_image_validation: true
  )
end

puts '-- Creating checkout transactions'
CheckoutCard.all.each do |card|
  Faker::Number.within(range: 0..10).times do
    checkout_products = CheckoutProduct.all
    checkout_products.reject(&:liquor?) if card.member.underage?

    CheckoutTransaction.create(
      checkout_card_id:            card.id,
      items:                       checkout_products.sample(Faker::Number.within(range: 1..3)).map(&:id),
      payment_method:              'Verkoop',
      created_at:                  Faker::Time.between(from: Time.now, to: card.member.join_date)
    )
  end
end
