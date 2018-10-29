#:nodoc:
class AddEmergencyPhoneNumberToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :emergency_phone_number, :string
  end
end
