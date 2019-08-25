class AddHciMasterToEducations < ActiveRecord::Migration[5.2]
  def up
    Study.create!(
      id:      8,
      code:    'HCI',
      masters: true
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
