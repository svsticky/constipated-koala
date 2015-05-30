class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :user_configurations, :id => false do |t|
      t.string :abbreviation, :unique => true
      t.string :name
      t.string :description
      
      t.string :value
      
      t.integer :config_type
      t.string :options
    end
    
    add_index :members, :student_id, unique: true
  end
end