class AddLedgerNrToGroups < ActiveRecord::Migration[6.0]
  def up
    add_column :groups, :ledgernr, :string, default: ""
    add_column  :groups,  :cost_location, :string, default: ""
    add_column :activities, :VAT, :string, default: "21"
  end

  def down
    remove_column :groups, :ledgernr
    remove_column :groups, :cost_location
    remove_column :activities, :VAT
  end

end
