class NormalizePhoneNumber < ActiveRecord::Migration[5.2]
  def up
    Member.find_each do |m|
      phone_number = normalize(m.phone_number)
      emergency_phone_number = normalize(m.emergency_phone_number)

      m.update_attribute :phone_number, phone_number
      m.update_attribute :emergency_phone_number, emergency_phone_number
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  # normalize and validate phone number
  def normalize(number)
    unless number.nil?
      if number.start_with?("06")
        number[0] = "+31"
      end

      if number.start_with?("00")
        number[0..1] = "+"
      end
    end

    number = TelephoneNumber.parse(number)

    return number.e164_number if number.valid?
    return nil
  end
end
