#:nodoc:
class ChangeIdealTable < ActiveRecord::Migration[4.2]
  def change
    add_column :ideal_transactions, :description, :string, after: :uuid
    add_column :ideal_transactions, :trxid, :string, after: :redirect_uri
    add_column :ideal_transactions, :amount, :decimal, after: :description, :scale => 2, :precision => 6
    add_column :ideal_transactions, :status, :string, after: :amount, :default => 'open'

    change_column :ideal_transactions, :uuid, :string, after: :trxid
    rename_column :ideal_transactions, :uuid, :token

    add_index :ideal_transactions, :token
    add_index :ideal_transactions, :trxid
  end
end
