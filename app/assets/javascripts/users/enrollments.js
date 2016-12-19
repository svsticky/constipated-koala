// Register all click handlers for enrollments
function bind_enrollments()
{

  // Registering for an activity
  // [POST] enrollments/:id
  $('#enrollments').find('button.enroll').on('click', enroll_activity);

  // De-registering for an activity
  // [DELETE] enrollments/:id
  $('#enrollments').find('button.cancel').on('click', cancel_activity);

  // add event handler to poster to show the modal
  $(".show-poster-modal").on("click", function ()
  {
    loadDataToModal(this);
    $('#poster-modal').modal('show');
  });

  // add event handler to go to the previous activity in the modal
  $("#prev-poster").on("click", function ()
  {
    prevPoster();
  });

  // add event handler to go to the next activity in the modal
  $("#next-poster").on("click", function ()
  {
    nextPoster();
  });
}

/**
 * loads the previous activity to the modal
 */
function prevPoster()
{
  loadDataToModal($(".panel-activity[data-activity-id=" + $("#activity-modal").attr("data-activity-id") + "]").parent().prev().children('.panel-activity'));
}

/**
 * loads the next activity to the modal
 */
function nextPoster()
{
  loadDataToModal($(".panel-activity[data-activity-id=" + $("#activity-modal").attr("data-activity-id") + "]").parent().next().children('.panel-activity'));
}

/**
 * Loads data of a panel-activity to the modal
 * @param node a node containing a panel-activity class
 */
function loadDataToModal(node)
{
  // find the panel activity
  var panelActivity = $(node).closest('.panel-activity');

  //load the poster of the panel activity in the modal
  $('#image-view').attr('src', panelActivity.find('.panel-body > .poster-thumbnail > .show-poster-modal > .small-poster').attr('src'));
  //load the title of the panel activity in the modal
  $('#activity-title').html(panelActivity.find('.panel-heading > .activity-title').html());
  //load the id of the panel activity in de modal
  $("#activity-modal").attr("data-activity-id", panelActivity.attr("data-activity-id"));

  //check if there are previous activities to go to
  if (panelActivity.parent().prev().length == 0)
  {
    $('#prev-poster').css("display", "none");
  } else
  {
    $('#prev-poster').css("display", "inline-block");
  }

  //check if there are any next activities to go to
  if (panelActivity.parent().next().length == 0)
  {
    $('#next-poster').css("display", "none");
  } else
  {
    $('#next-poster').css("display", "inline-block");
  }
}

$(document).on('ready page:load', bind_enrollments);

//Enroll user for activity when clicked
function enroll_activity()
{
  if (!confirm("Je wordt ingeschreven voor deze activiteit. Weet je het zeker?"))
    return;
  var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
  var activity = $(this).closest('.panel');
  var activity_id = activity.attr('data-activity-id');
  var activity_button = this;
  var activity_participants = activity.find('.activity-count')[0];
  var activity_title = activity.find('.activity-title')[0];

  $.ajax({
    url: '/enrollments/' + activity_id,
    type: 'POST',
    data: {
      authenticity_token: token
    }
  }).done(function (resp)
  {
    //Alert user of  enrollment
    alert('Je hebt je ingeschreven voor ' + activity_title.textContent, 'success');

    //Update button color and event-handler
    $(activity_button)
      .toggleClass('enroll btn-success cancel btn-warning')
      .off('click')
      .on('click', cancel_activity)

    //Toggle button icon and text, update participant counts
    $($(activity_button).children()[0]).toggleClass('fa-times fa-check');
    activity_button.innerText = "Uitschrijven";
    if (resp.participant_limit == null)
      activity_participants.innerText = resp.participant_count;
    else
    {
      if (resp.participant_count >= resp.participant_limit)
        activity_participants.innerText = "VOL!";
      else
        activity_participants.innerText = resp.participant_count + ' / ' + resp.participant_limit;
    }
  }).fail(function (data)
  {
    if (!data.responseJSON)
    {
      data.responseJSON = {message: 'Could not enroll for activity'};
    }
    alert(data.responseJSON.message, 'error');
  });
}

//Cancel user's enrollment when clicked
function cancel_activity()
{
  if (!confirm("Je schrijft je uit voor deze activiteit. Weet je het zeker?"))
    return;
  var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
  var activity = $(this).closest('.panel');
  var activity_id = activity.attr('data-activity-id');
  var activity_button = this;
  var activity_participants = activity.find('.activity-count')[0];
  var activity_title = activity.find('.activity-title')[0];

  $.ajax({
    url: '/enrollments/' + activity_id,
    type: 'DELETE',
    data: {
      authenticity_token: token
    }
  }).done(function (resp)
  {
    //Alert user of cancellation of enrollment
    alert('Je bent uitgeschreven voor ' + activity_title.textContent, 'warning');

    //Update button color and event-handler
    $(activity_button)
      .toggleClass('cancel btn-warning enroll btn-success')
      .off('click')
      .on('click', enroll_activity);

    //Toggle button icon and text, update participant counts
    $($(activity_button).children()[0]).toggleClass('fa-check fa-times');
    activity_button.innerText = "Inschrijven";
    if (resp.participant_limit == null)
      activity_participants.innerText = resp.participant_count;
    else
    {
      if (resp.participant_count >= resp.participant_limit)
        activity_participants.innerText = "VOL!";
      else
        activity_participants.innerText = resp.participant_count + ' / ' + resp.participant_limit;
    }

  }).fail(function (data)
  {
    if (!data.responseJSON)
    {
      data.responseJSON = {message: 'Could not cancel enrollment for activity'};
    }
    alert(data.responseJSON.message, 'error');
  });
}
