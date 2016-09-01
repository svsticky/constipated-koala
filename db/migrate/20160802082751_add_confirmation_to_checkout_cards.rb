class AddConfirmationToCheckoutCards < ActiveRecord::Migration
  def change
	change_table :checkout_cards do |t|
      t.string   :confirmation_token
    end
  end
end
