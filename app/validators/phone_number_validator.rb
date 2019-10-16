# Checks if a phone number is valid using the telephone_number gem
class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :invalid) unless TelephoneNumber.parse(value).valid?
  end
end
