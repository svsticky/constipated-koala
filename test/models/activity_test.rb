require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  test 'Blank Activity is invalid' do
    a = Activity.new
    assert_not a.save
  end
end
