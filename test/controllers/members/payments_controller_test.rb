require 'test_helper'

class PaymentsControllerTest < ActiveSupport::TestCase
  test 'should display all activity names when concat is shorter than description maxLength' do
    coll = %w[should display all]
    res = Members::PaymentsController.join_with_char_limit(coll, ", ", 100)

    assert_equal coll.join(", "), res
  end

  test 'should display maximum amount of activity names when total concat is larger than description maxLength' do
    coll = %w[should display twoOfTheseStrings]
    res = Members::PaymentsController.join_with_char_limit(coll, ", ", 24)

    assert_includes res, "should"
    assert_includes res, "display"
    assert_not_includes res, "two"
  end

  test 'should display all activity names when suffix longer than last string and total within maxLength' do
    coll = %w[theLastStringWillBeVery tiny]
    just_enough_space = Members::PaymentsController.join_with_char_limit(coll, ", ", 29)
    assert_equal coll.join(", "), just_enough_space

    coll = %w[tiny tiny tiny]
    just_enough_space = Members::PaymentsController.join_with_char_limit(coll, ", ", 16)
    assert_equal coll.join(", "), just_enough_space
  end

  test 'should account for suffix length in inclusion of activity names' do
    coll = %w[theLastStringWillBeVery tiny]
    too_little_space = Members::PaymentsController.join_with_char_limit(coll, ", ", 28)
    assert too_little_space.length <= 28
    assert_not_includes too_little_space, coll[0]
    assert_not_includes too_little_space, coll[1]
  end

  test 'should exclude last activity name when suffix is shorter than' \
       'last string and total would otherwise exceed maxLength' do
    coll = %w[C1 C2 SomeArbitraryLargeString]
    val = Members::PaymentsController.join_with_char_limit(coll, ", ", 15)

    assert_includes val, "C1"
    assert_includes val, "C2"
    assert_not_includes val, "SomeArbitraryLargeString"
    assert_includes val, "1 meer"
    assert val.length <= 15
  end

  test 'should exclude multiple small activity-names when suffix will be present' do
    coll = %w[C1 C2 C3 SomeArbitraryLargeString]
    val = Members::PaymentsController.join_with_char_limit(coll, ", ", 15)
    assert_includes val, "C1"
    assert_includes val, "C2"
    assert_not_includes val, "C3"
    assert_not_includes val, "SomeArbitraryLargeString"
    assert_includes val, "2 meer"
    assert val.length <= 15
  end
end
