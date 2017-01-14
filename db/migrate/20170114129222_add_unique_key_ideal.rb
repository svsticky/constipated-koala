class AddUniqueKeyIdeal < ActiveRecord::Migration
  def change
    change_column :ideal_transactions, :status, :string, :default => 'open', :limit => 9
    change_column :ideal_transactions, :token, :string, :limit => 64

    remove_index :ideal_transactions, :token
    add_index :ideal_transactions, :token, :unique => true

    remove_index :ideal_transactions, :trxid
    add_index :ideal_transactions, :trxid, :unique => true
  end
end
