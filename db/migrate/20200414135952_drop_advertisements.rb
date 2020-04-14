class DropAdvertisements < ActiveRecord::Migration[6.0]
  def change
    drop_table :advertisements
  end
end
