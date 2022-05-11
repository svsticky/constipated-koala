require 'test_helper'

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! 'koala.rails.local'
  end

  test 'should get activities' do
    get '/api/activities'
    assert_response :success

    data = JSON.parse(@response.body) # @response is set automagically on get

    # Assert that we see all activities we should
    should_see = Activity.where(is_viewable: true).to_a
    should_see.reject!(&:ended?)

    assert_equal should_see.count, data.count

    seen_names = data.map { |a| a["name"] }

    should_see.each do |a|
      assert_includes seen_names, a.name
    end
  end
end
