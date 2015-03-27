class CreateIdealTransactions < ActiveRecord::Migration
  def change
    drop_table :ideal_transactions
    
    create_table :ideal_transactions, :id => false do |t|  
      t.string :uuid, :unique => true, :limit => 16
      
      t.belongs_to :member
      
      t.string :transaction_type
      t.string :transaction_id
    
      t.timestamps
    end
  end
end
