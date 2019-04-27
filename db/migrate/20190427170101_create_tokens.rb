class CreateTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      t.string :token, :null => false
      t.belongs_to :object, :polymorphic => true, :null => false

      t.timestamps
      t.datetime :expires_at, :null => false
    end
  end
end
