class CreateStockyTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :stocky_transactions do |t|
      t.references :product
      t.integer :amount, null: false
      t.string :from, null: false
      t.string :to, null: false

      t.timestamps
    end
  end
end
