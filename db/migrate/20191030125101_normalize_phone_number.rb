class NormalizePhoneNumber < ActiveRecord::Migration[5.2]
  def up
    change_column :members, :phone_number, :string do |t|
      if (t.start_with?("06"))
        t[0] = "+31"
      end

      if (t.start_with?("00"))
        t[0..1] = "+"
      end
      
      if (TelephoneNumber.parse(t).valid?)
        t = TelephoneNumber.parse(t).e164_number
      else
        t = nil
      end

      return t
    end
  end

  def down
    change_column :members, :phone_number, :string do |t|
      if (t.start_with?("+"))
        t[0] = "00"
      end
      
      return t
    end
  end
end
