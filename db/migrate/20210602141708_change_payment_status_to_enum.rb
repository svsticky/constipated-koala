class ChangePaymentStatusToEnum < ActiveRecord::Migration[6.0]
  def up
    add_column :payments, :status_tmp, :integer, default:  0
    Payment.reset_column_information
    Payment.where(:status => ['paid','paidout']).update_all(:status_tmp => 2)
    remove_column :payments, :status
    rename_column :payments, :status_tmp, :status
  end

  def down
    change_column :payments, :status, :string
  end
end
