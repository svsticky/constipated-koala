require 'test_helper'

# Easy test script calling pages and testing if no error page is shown
class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! 'koala.rails.local'
  end

  # # TODO: age is checked in controllers, so moved this to controller.
  # test "minors not being able to enroll for 18+ activities" do
  #   a = activities(:test_activities_3)
  #
  #   m1 = members(:m8eld) # underage
  #   assert m1.underage?, "Expected member being underage, but this member has grown up quite a bit"
  #
  #   m2 = members(:thecreator) # adult
  #   assert m2.adult?, "Expected member being 18+, but this member hasn't left puberty yet"
  #
  #   participant = Participant.create!(
  #     member: m1,
  #     activity: a,
  #     reservist: false
  #   )
  #
  #   assert_not participant.save!, "Expected Machteld not being able to enroll, but she did"
  # end
end
