class AddDsMasterToEducations < ActiveRecord::Migration[6.1]
  def up
    Study.create!(
      code:    'DS',
      masters: true
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
