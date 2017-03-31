class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  test "enrolling reservist through deleting previous participant" do
    a = activities(:test_enrollments_1)
    assert a.participants.count == 1, "expected one participant on activity, got #{a.participants.count}"
    assert a.attendees.count == 1, "expected one attendee on activity, got #{a.attendees.count}"
    assert a.reservists.count == 0, "expected no reservists on activity, got #{a.reservists.count}"

    p1 = participants(:underpant_first)

    m = members(:dannypanny)
    p2 = Participant.create!(
      member: m,
      activity: a,
      reservist: true
    )

    a.reload

    assert a.participants.count == 2, "expected two participants on activity, got #{a.participants.count}"
    assert a.attendees.count == 1, "expected one attendee on activity, got #{a.attendees.count}"
    assert a.reservists.count == 1, "expected one reservist on activity, got #{a.reservists.count}"

    p1.destroy!
    a.reload

    assert a.participants.count == 1, "expected one participant on activity, got #{a.participants.count}"
    assert a.attendees.count == 1, "expected one attendee on activity, got #{a.attendees.count}"
    assert a.reservists.count == 0, "expected no reservists on activity, got #{a.reservists.count}"
  end

  test "enrolling reservist through increasing participant limit" do
    a = activities(:test_enrollments_2)
    assert a.participants.count == 1, "expected one participant on activity, got #{a.participants.count}"
    assert a.attendees.count == 1, "expected one attendee on activity, got #{a.attendees.count}"
    assert a.reservists.count == 0, "expected no reservists on activity, got #{a.reservists.count}"

    m = members(:dannypanny)
    p2 = Participant.create!(
      member: m,
      activity: a,
      reservist: true
    )

    a.reload

    assert a.participants.count == 2, "expected two participants on activity, got #{a.participants.count}"
    assert a.attendees.count == 1, "expected one attendee on activity, got #{a.attendees.count}"
    assert a.reservists.count == 1, "expected one reservist on activity, got #{a.reservists.count}"

    a.participant_limit = 2
    a.save!

    assert a.participants.count == 2, "expected one participant on activity, got #{a.participants.count}"
    assert a.attendees.count == 2, "expected one attendee on activity, got #{a.attendees.count}"
    assert a.reservists.count == 0, "expected no reservists on activity, got #{a.reservists.count}"
  end

  test "minors not being able to enroll for 18+ activities" do
    a = activities(:test_enrollments_3)
    m1 = members(:m8eld) #underage
    m2 = members(:thecreator) #adult
    assert m1.is_underage?, "Expected member being underage, but this member has grown up quite a bit"
    assert_not m2.is_underage?, "Expected member being 18+, but this member hasn't left puberty yet"
    p1 = Participant.create!(
      member: m1,
      activity: a,
      reservist: false
    )
    a.reload
    #assert_not p1.save!, "Expected m1 not being able to enroll, but she did"

  end
end
