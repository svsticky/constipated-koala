class AddDisabledToCheckoutCards < ActiveRecord::Migration[6.0]
  def up
    add_column :checkout_cards, :disabled, :boolean, default: false
  end

  def down
    remove_column :checkout_cards, :disabled
  end
end
