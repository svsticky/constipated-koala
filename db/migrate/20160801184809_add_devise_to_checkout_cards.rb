class AddDeviseToCheckoutCards < ActiveRecord::Migration
  def change
    change_table :checkout_cards do |t|
  	  ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
      t.string   :email
    end
  end
end