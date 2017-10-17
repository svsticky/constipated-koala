class AddConfirmationToCheckoutCards < ActiveRecord::Migration[4.2]
  def change
  change_table :checkout_cards do |t|
      t.string :confirmation_token
    end
  end
end
