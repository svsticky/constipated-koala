class AddAdsMasterToEducations < ActiveRecord::Migration[5.2]
    def up
      Study.create!(
        code:    'ADS',
        masters: true
      )
    end
  
    def down
      raise ActiveRecord::IrreversibleMigration
    end
  end
  