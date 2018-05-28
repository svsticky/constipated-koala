class CreateIdealTransactions < ActiveRecord::Migration[4.2]
  def change
    drop_table :ideal_transactions if ApplicationRecord.connection.table_exists? 'ideal_transactions'

    create_table :ideal_transactions, :id => false do |t|
      t.string :uuid, :unique => true, :limit => 16

      t.belongs_to :member

      t.string :transaction_type
      t.string :transaction_id

      t.timestamps
    end

    # create unique email for login
    add_index :members, :email, :unique => true
  end
end
