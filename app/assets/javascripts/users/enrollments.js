// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

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

function enroll_activity() {
	var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
	var activity = $(this).closest('tr');
	var activity_id = activity.attr('data-activity-id');

	$.ajax({
		url: '/enrollments/' + activity_id,
		type: 'POST',
		data: {
			authenticity_token: token
		}
	}).done(function(){
		alert('Je hebt je ingeschreven voor ' + activity.html(), 'success');
        $(row).find( 'button.enroll' ).empty().removeClass( 'enroll btn-success' ).addClass( 'cancel btn-danger' ).append( '<i class="fa fa-fw fa-check"></i>' );

		// todo: update knop bijwerken
		// knophandlers opnieuw?
	}).fail(function(){
		alert('Hij doet het niet hij doet het niet', 'error');
	});
}

function cancel_activity() {
	var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
	var activity = $(this).closest('tr');
	var activity_id = activity.attr('data-activity-id');

	$.ajax({
		url: '/enrollments/' + activity_id,
		type: 'DELETE',
		data: {
			authenticity_token: token
		}
	}).done(function(){
		alert('Je bent uitgeschreven van ' + activity.html(), 'success');

		// zelfde todos
	}).fail(function(){
        $(row).find( 'button.cancel' ).empty().removeClass( 'cancel btn-danger' ).addClass( 'enroll btn-success' ).append( '<i class="fa fa-fw fa-check"></i>' );
		alert('Hij doet het alweer niet', 'error');
	});
}
