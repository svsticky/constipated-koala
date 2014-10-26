class CreateCheckoutTables < ActiveRecord::Migration
  def change
    create_table :checkout_balances do |t|
      
      t.decimal :balance, :scale => 2, :precision => 6
      t.belongs_to :member, :null => false
      
      t.timestamps
    end
    
    create_table :checkout_cards do |t|
    
      t.string :uuid, :unique => true, :limit => 16, :null => false
      t.text :description
      t.boolean :active

      t.belongs_to :member, :null => false
      t.belongs_to :checkout_balance, :null => false

      t.timestamps
    end
    
    create_table :checkout_transactions do |t|
    
      t.decimal :price, :scale => 2, :precision => 6, :null => false
      t.belongs_to :checkout_card
      
      t.timestamps
    end
    
    add_index :checkout_cards, :uuid, unique: true
  end
end
