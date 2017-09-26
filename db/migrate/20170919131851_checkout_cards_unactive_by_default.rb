class CheckoutCardsUnactiveByDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :checkout_cards, :active, from: nil, to: 0
  end
end
