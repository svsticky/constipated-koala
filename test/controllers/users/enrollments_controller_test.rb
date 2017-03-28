class ArticlesControllerTest < ActionDispatch::IntegrationTest
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
end
