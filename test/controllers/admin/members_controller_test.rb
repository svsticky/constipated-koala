require 'test_helper'

# :nodoc:
class MembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! 'koala.rails.local'
    sign_in users(:martijn)

    @member = members(:yorici)
  end

  teardown do
  end

  test 'should show active members' do
    get members_url
    assert_response :success
  end

  test 'should show member page' do
    get member_url(@member)
    assert_response :success
  end

  test 'should destroy member' do
    assert_difference('Member.count', -1) do
      delete member_url(@member)
    end

    assert_redirected_to root_url
  end
end
