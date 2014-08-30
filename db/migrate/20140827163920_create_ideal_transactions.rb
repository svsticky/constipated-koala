class CreateIdealTransactions < ActiveRecord::Migration
  def change
    create_table :ideal_transactions do |t|  
      t.string :uuid, :unique => true, :limit => 16
      
      t.text :description
      t.decimal :price, :scale => 2, :precision => 6
      
      t.belongs_to :member
      t.string :activities
      
      t.string :issuer, :limit => 8
      t.string :status, :limit => 9
      
      t.string :iban, :limit => 34
      t.string :url
    
      t.timestamps
    end
  end
end
