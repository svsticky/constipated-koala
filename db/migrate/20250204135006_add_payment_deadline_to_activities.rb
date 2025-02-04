class AddPaymentDeadlineToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :payment_deadline, :date
  end
end
