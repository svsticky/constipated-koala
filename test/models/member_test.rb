require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  test 'Blank Member is invalid' do
    m = Member.new
    assert_not m.save
  end

  # This hash lists all attributes that are required for a member to be valid,
  # along with a purposefully empty/invalid value.
  minimal_required_attributes = {
    'first_name' => '', 'last_name' => '',
    'address' => '', 'house_number' => '', 'postal_code' => '', 'city' => '',
    'phone_number' => '', 'emergency_phone_number' => '', 'email' => '',
    'birth_date' => nil, 'join_date' => nil, 'calendar_id' => ''
  }

  # Verify that a Member model with the minimal set of attributes defined above
  # is valid, AND that this set is actually the minimal set of attributes,
  # meaning that the model is invalid if any of these values are missing.
  test 'filled-out Member is valid' do
    m = Member.new
    m.first_name = 'Test_first'
    m.last_name = 'Test_last'
    m.address = 'Teststreet'
    m.house_number = '123' # Not a number, to allow for 'bis', 'A', etc.
    m.postal_code = '1234 AB'
    m.city = 'Testville'
    m.phone_number = '+31655548806'
    m.emergency_phone_number = '+31655548806'
    m.email = 'test@svsticky.nl'
    m.birth_date = Date.today
    m.join_date = Date.today

    assert m.save, 'Could not save minimal valid Member'

    minimal_required_attributes.each do |attribute, emptyvalue|
      temp = m.attributes[attribute]
      m.assign_attributes(attribute => emptyvalue)

      assert_not m.save, "#{ attribute } is not required"

      m.assign_attributes(attribute => temp)
    end
  end

  # Verify that a Member may have either a valid student number or no student
  # number at all, but not an invalid student number.
  test 'Student number valid when present' do
    m = members(:martyparty)

    m.student_id = '5636450'
    assert m.save, 'Valid numerical student number marked invalid'

    m.student_id = 'F133742'
    assert m.save, 'F-number marked invalid'

    m.student_id = '000000'
    assert_not m.save, 'Invalid student id marked valid'

    m.student_id = ''
    assert m.save, 'Blank student id marked invalid'
  end

  test 'Email valid when present' do
    m = members(:martyparty)

    m.email = 'testemail@hotmail.com'
    assert m.save, 'Valid email address marked invalid'

    m.email = 'testemail.hotmail.com'
    assert_not m.save, 'Invalid email marked as valid, contains no @'

    m.email = 'testemail@hotmail'
    assert_not m.save, 'Invalid email marked as valid, contains no TLD'

    m.email = ''
    assert_not m.save, 'Blank email marked invalid'
  end
end
