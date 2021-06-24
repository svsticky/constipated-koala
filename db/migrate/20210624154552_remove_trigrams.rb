class RemoveTrigrams < ActiveRecord::Migration[6.0]
  def up
    drop_table :trigrams
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
