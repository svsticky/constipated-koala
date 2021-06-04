class AddPayableToActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :is_payable, :boolean, :default => false
  end
end
