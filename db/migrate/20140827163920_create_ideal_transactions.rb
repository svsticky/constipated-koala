class CreateIdealTransactions < ActiveRecord::Migration
  def change
    create_table :ideal_transactions, id: false do |t|  
      t.string :uuid, :null => false, :unique => true, :limit => 36
      
      t.text :description
      t.decimal :price, :scale => 2, :precision => 6
      
      t.belongs_to :member
      t.string :activities
      
      t.string :issuer, :limit => 8
      t.string :status, :limit => 9
      
#      t.string :iban, :limit => 34
    
      t.timestamps
    end
    
    add_index :ideal_transactions, :uuid, unique: true
  end
end
