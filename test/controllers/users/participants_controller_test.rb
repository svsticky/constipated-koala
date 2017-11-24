require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  def assert_counts(activity, expected_counts)
    # Assert that an activity's participant counts match the given values.
    actual_counts = activity.participant_counts

    assert expected_counts[0] == expected_counts[1] + expected_counts[2],
      "fix your tests, unbalanced number of attendees and reservists."

    [[0,'participants'], [1,'attendees'], [2, 'reservists']].each do |t|
      pos = t[0]
      type = t[1]

      assert_equal expected_counts[pos], actual_counts[pos], "#{type} count doesn't match"
    end
  end

  test "enrolling reservist through deleting previous participant" do
    a = activities(:test_activities_1)
    assert_counts(a, [1,1,0])

    p1 = participants(:underpant_first)

    m = members(:dannypanny)
    p2 = Participant.create!(
      member: m,
      activity: a,
      reservist: true
    )

    a.reload

    assert_counts(a, [2,1,1])

    p1.destroy!
    a.reload

    assert_counts(a, [1,1,0])
  end

  test "enrolling reservists will not exceed limits" do
    a = activities(:test_activities_3)
    assert_counts(a, [1,1,0])

  end

  test "enrolling reservist through increasing participant limit" do
    a = activities(:test_activities_2)
    assert_counts(a, [1,1,0])

    m = members(:dannypanny)
    p2 = Participant.create!(
      member: m,
      activity: a,
      reservist: true
    )

    a.reload

    assert_counts(a, [2,1,1])

    a.participant_limit = 2
    a.save!

    assert_counts(a, [2,2,0])
  end

  test "minors not being able to enroll for 18+ activities" do
    a = activities(:test_activities_3)
    m1 = members(:m8eld) #underage
    m2 = members(:thecreator) #adult
    assert m1.is_underage?, "Expected member being underage, but this member has grown up quite a bit"
    assert m2.is_adult?, "Expected member being 18+, but this member hasn't left puberty yet"
    p1 = Participant.create!(
      member: m1,
      activity: a,
      reservist: false
    )
    a.reload
    #assert_not p1.save!, "Expected m1 not being able to enroll, but she did"
  end

  test "luckypeople selection for master's activities not broken" do
    a = activities(:test_luckypeople_masters)
    a.enroll_reservists

    assert_counts(a, [3, 1, 2])
    assert_equal a.attendees.first, members(:masterboy030man)
  end
end
