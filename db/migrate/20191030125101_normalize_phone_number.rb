class NormalizePhoneNumber < ActiveRecord::Migration[5.2]
  def up
    Member.find_each do |m|
      # duplicate numbers in case we need the old number
      new_phone_number = normalize(m.phone_number.dup)
      new_emergency_phone_number = normalize(m.emergency_phone_number.dup)

      comments = m.comments || ""
      comments << "\nMember had invalid phone number #{m.phone_number}" if new_phone_number.nil?
      comments << "\nMember had invalid emergency phone number #{m.emergency_phone_number}" if new_phone_number.nil? && m.emergency_phone_number.present?

      m.update phone_number: new_phone_number
      m.update emergency_phone_number: new_emergency_phone_number
      m.update comments: comments
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  # normalize and validate phone number
  def normalize(number)
    unless number.nil?
      if number =~ /^0[^0]/   # match dutch landlines and mobile numbers
        number[0] = "+31"
      end

      if number.start_with?("00")   # other international numbers
        number[0..1] = "+"
      end
    end

    number = TelephoneNumber.parse(number)

    return number.e164_number if number.valid?
    return nil
  end
end
