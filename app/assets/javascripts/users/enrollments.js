$(document).on('ready page:load', bind_enrollments);

/**
 * Register all click handlers for enrollments
 */
function bind_enrollments() {

  //Registering for an activity
  //[POST] enrollments/:id
  $('#enrollments').find('button.enroll').on('click', enroll_activity);

  //De-registering for an activity
  //[DELETE] enrollments/:id
  $('#enrollments').find('button.cancel').on('click', cancel_activity);

  //Add event handler to poster to show the modal
  $(".show-poster-modal").on("click", function () {
    loadDataToModal($(this).closest('.panel-activity'));
    $('#poster-modal').modal('show');
  });

  //Add event handler to go to the previous activity in the modal
  $("#prev-poster").on("click", function () {
    prevPoster();
  });

  //Add event handler to go to the next activity in the modal
  $("#next-poster").on("click", function () {
    nextPoster();
  });
}

/**
 * Loads the previous activity to the modal
 */
function prevPoster() {
  var currentID = $("#activity-modal").attr("data-activity-id");
  var currentActivity = $(".panel-activity[data-activity-id=" + currentID + "]");
  var prevActivity = currentActivity.parent().prev().find('.panel-activity');

  loadDataToModal(prevActivity);
}

/**
 * Loads the next activity to the modal
 */
function nextPoster() {
  var currentID = $("#activity-modal").attr("data-activity-id");
  var currentActivity = $(".panel-activity[data-activity-id=" + currentID + "]");
  var nextActivity = currentActivity.parent().next().find('.panel-activity');

  loadDataToModal(nextActivity);
}

/**
 * Loads data of a panel-activity to the modal
 * @param panelActivity a node containing a panel-activity class
 */
function loadDataToModal(panelActivity) {
  //Load the poster of the panel activity in the modal
  $('#image-view').attr('src', panelActivity.find('.small-poster').attr('src').replace('thumb', 'medium'));

  //set the more info href
  $('#more-info-link').attr('href', panelActivity.find('.more-info').attr('href'));

  //Load the title of the panel activity in the modal
  $('#activity-title').html(panelActivity.find('.activity-title').html());

  //Load the id of the panel activity in de modal
  $("#activity-modal").attr("data-activity-id", panelActivity.attr("data-activity-id"));

  //Check if there are previous activities to go to
  if (panelActivity.parent().prev().length == 0) {
    $('#prev-poster').css("display", "none");
  } else {
    $('#prev-poster').css("display", "inline-block");
  }

  //Check if there are any next activities to go to
  if (panelActivity.parent().next().length == 0) {
    $('#next-poster').css("display", "none");
  } else {
    $('#next-poster').css("display", "inline-block");
  }
}


/**
 * Enroll user for activity when clicked
 */
function enroll_activity() {
  if (!confirm("Je wordt ingeschreven voor deze activiteit. Weet je het zeker?"))
    return;

  var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
  var activity = $(this).closest('.panel');
  var activity_id = activity.attr('data-activity-id');
  var activity_button = this;
  var activity_participants = activity.find('.activity-count')[0];
  var activity_title = activity.find('.activity-title')[0];
	var date_unsplit = activity.find('.activity-unenroll')[0]
	if(typeof date_unsplit !== "undefined"){
		var date_split = date_unsplit.innerText.split("/");
		var activity_unenroll = new Date(date_split[2], date_split[1]-1, date_split[0])
		if($.now()>activity_unenroll){
			if(!confirm("De uitschrijfdeadline voor deze activiteit is verstreken. Je inschrijving kan dus niet ongedaan gemaakt worden. Weet je heel zeker dat je je wilt inschrijven")){
				return;
			}
		}
	}

  response = $.ajax({
    url: '/enrollments/' + activity_id,
    type: 'POST',
    data: {
      authenticity_token: token
    }
  }).done(function (activity) {
    //Alert user of  enrollment
    alert(activity.message, 'success');

    var button_text, button_class;

    //Normal enrollment
    if (response.status == 200) {
      button_text = "Uitschrijven";
      button_class = "btn-danger"
    //Back-up list enrollments
    } else if (response.status == 202) {
      button_text = "Reservelijst"
      button_class = "btn-warning"
    }

    //Update button color and event-handler
    $(activity_button)
      .toggleClass('enroll btn-success cancel ' + button_class)
      .off('click')
      .on('click', cancel_activity)

    //Toggle button icon and text, update participant counts
    $($(activity_button).children()[0]).toggleClass('fa-times fa-check');
    activity_button.innerText = button_text;
    updateParticipantsLimit(activity, activity_participants);

  }).fail(function (data) {
    if (!data.responseJSON) {
      data.responseJSON = {message: 'Could not enroll for activity'};
    }
    alert(data.responseJSON.message, 'error');
  });
}

/**
 * Cancel user's enrollment when clicked
 */
function cancel_activity() {
  var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
  var activity = $(this).closest('.panel');
  var activity_id = activity.attr('data-activity-id');
  var activity_button = this;
  var activity_participants = activity.find('.activity-count')[0];
  var activity_title = activity.find('.activity-title')[0];
	var date_unsplit = activity.find('.activity-unenroll')[0]
	if(typeof date_unsplit !== "undefined"){
		var date_split = date_unsplit.innerText.split("/");
		var activity_unenroll = new Date(date_split[2], date_split[1]-1, date_split[0])
		if($.now()>activity_unenroll){
			alert("Je kunt je niet meer uitschrijven na de uitschrijfdeadline, sorry :(")
			return;
		}
	}

	if (!confirm("Je schrijft je uit voor deze activiteit. Weet je het zeker?"))
		return;

  $.ajax({
    url: '/enrollments/' + activity_id,
    type: 'DELETE',
    data: {
      authenticity_token: token
    }
  }).done(function (activity) {
    //Alert user of cancellation of enrollment
    alert(activity.message, 'warning');

    //Update button color and event-handler
    $(activity_button)
      .removeClass('btn-danger btn-warning')
      .toggleClass('cancel enroll btn-success')
      .off('click')
      .on('click', enroll_activity);

    //Toggle button icon and text, update participant counts
    $($(activity_button).children()[0]).toggleClass('fa-check fa-times');
    activity_button.innerText = "Inschrijven";
    updateParticipantsLimit(activity, activity_participants);

  }).fail(function (data) {
    if (!data.responseJSON) {
      data.responseJSON = {message: 'Could not enroll for activity'};
    }
    alert(data.responseJSON.message, 'error');
  });
}

/**
 * Update the participants
 * @activity Activity in json
 * @activity_partipants Element indicating the number of participants
 */
function updateParticipantsLimit(activity, activity_participants) {
  if (activity.participant_limit == null)
    activity_participants.innerText = activity.participant_count;
  else {
    if (activity.participant_count >= activity.participant_limit)
      activity_participants.innerText = "VOL!";
    else
      activity_participants.innerText = activity.participant_count + ' / ' + activity.participant_limit;
  }
}
