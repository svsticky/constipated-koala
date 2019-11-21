class NormalizePhoneNumber < ActiveRecord::Migration[5.2]
  def up
    Member.find_each do |m|
      # duplicate numbers in case we need the old number
      phone_number = normalize(m.phone_number.dup)
      emergency_phone_number = normalize(m.emergency_phone_number.dup)

      comments = m.comments

      if phone_number.nil?
        comments = log_invalid_number(m.phone_number, comments, false)
      end

      if emergency_phone_number.nil?
        comments = log_invalid_number(m.emergency_phone_number, comments, true)
      end

      m.update_attribute :phone_number, phone_number
      m.update_attribute :emergency_phone_number, emergency_phone_number
      m.update_attribute :comments, comments
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

  # add previous number to member comments
  def log_invalid_number(number, comments, emergency)
    if comments.nil?
      comments = ""
    else
      comments.concat("\n")
    end

    comments.concat("Member had invalid #{emergency ? "emergency" : ""} phone number: #{number}")
  end
end
