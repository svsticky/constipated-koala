// Register all click handlers for enrollments
function bind_enrollments() {

	// Registering for an activity
	// [POST] enrollments/:id
	$('#enrollments').find('button.enroll').on('click', enroll_activity);

	// De-registering for an activity
	// [DELETE] enrollments/:id
	$('#enrollments').find('button.cancel').on('click', cancel_activity);
}

$(document).on('ready page:load', bind_enrollments);

//Enroll user for activity when clicked
function enroll_activity() {
	if(!confirm("Weet je zeker dat je je in wilt schrijven voor deze activiteit?"))
		return;
	var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
	var activity = $(this).closest('.panel');
	var activity_id = activity.attr('data-activity-id');
  var activity_button = this;

	$.ajax({
		url: '/enrollments/' + activity_id,
		type: 'POST',
		data: {
			authenticity_token: token
		}
	}).done(function(resp) {
		//Alert user of  enrollment
		alert('Je hebt je ingeschreven voor ' + activity.find('.activity-title')[0].textContent, 'success');

		//Update button color and event-handler
    $(activity_button)
      .toggleClass('enroll btn-success cancel btn-warning')
      .off('click')
      .on('click', cancel_activity)

		//Toggle button icon and text, update participant counts
    $($(activity_button).children()[0]).toggleClass('fa-times fa-check');
		activity_button.innerText = "Uitschrijven";
		if(resp.participant_limit == null)
			activity.find('.activity-count')[0].innerText = resp.participant_count;
		else {
			if(resp.participant_count >= resp.participant_limit)
				activity.find('.activity-count')[0].innerText = "VOL!";
			else
				activity.find('.activity-count')[0].innerText = resp.participant_count + ' / ' + resp.participant_limit;
		}
	}).fail(function(data) {
      if (!data.responseJSON) {
        data.responseJSON = { message: 'Could not enroll for activity'};
      }
      alert(data.responseJSON.message, 'error');
	});
}

//Cancel user's enrollment when clicked
function cancel_activity() {
	if(!confirm("Weet je zeker dat je je uit wilt schrijven voor deze activiteit?"))
		return;
	var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
	var activity = $(this).closest('.panel');
	var activity_id = activity.attr('data-activity-id');
  var activity_button = this;

	$.ajax({
		url: '/enrollments/' + activity_id,
		type: 'DELETE',
		data: {
			authenticity_token: token
		}
	}).done(function(resp) {
    //Alert user of cancellation of enrollment
		alert('Je bent NIET meer ingeschreven voor ' + activity.find('.activity-title')[0].textContent, 'warning');

    //Update button color and event-handler
    $(activity_button)
      .toggleClass('cancel btn-warning enroll btn-success')
      .off('click')
      .on('click', enroll_activity)

    //Toggle button icon and text, update participant counts
    $($(activity_button).children()[0]).toggleClass('fa-check fa-times');
		activity_button.innerText = "Inschrijven";
		if(resp.participant_limit == null)
			activity.find('.activity-count')[0].innerText = resp.participant_count;
		else {
			if(resp.participant_count >= resp.participant_limit)
				activity.find('.activity-count')[0].innerText = "VOL!";
			else
				activity.find('.activity-count')[0].innerText = resp.participant_count + ' / ' + resp.participant_limit;
		}

	}).fail(function(data) {
      if (!data.responseJSON) {
        data.responseJSON = { message: 'Could not cancel enrollment for activity'};
      }
      alert(data.responseJSON.message, 'error');
	});
}
;
