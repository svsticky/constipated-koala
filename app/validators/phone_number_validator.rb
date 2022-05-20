# Checks if a phone number is valid using the telephone_number gem
# The telephone_number gem only checks if the string contains a valid phone number,
# not if the string *only* contains a valid phone number.
# This is why the second part is needed to compare the string with all
# non-numberic characters removed to the original string.
class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless TelephoneNumber.parse(value).valid? && value.to_i.to_s == value.gsub(
      "+", ""
    )
      record.errors.add(attribute,
                        :invalid)
    end
  end
end
