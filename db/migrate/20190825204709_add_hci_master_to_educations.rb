class AddHciMasterToEducations < ActiveRecord::Migration[5.2]
  def up
    Study.create!(
      code:    'HCI',
      masters: true
    )
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
