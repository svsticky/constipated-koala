//= require sweetalert

//TODO modal class
//TODO poster nav button hide/show to modol class

var token, modal, activity_container;

/**
 * Converts a string with format rgb(int, int, int) to hex value
 * @param rgb
 * @returns {string}
 */
function rgbToHex(rgb){
  var parts = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
  delete(parts[0]);
  for (var i = 1; i <= 3; ++i) {
    parts[i] = parseInt(parts[i]).toString(16);
    if (parts[i].length == 1) parts[i] = '0' + parts[i];
  }
  return '#' + parts.join('');
}

function confirm_enroll(activity) {
  swal({
      title: "Je wordt ingeschreven voor deze activiteit. Weet je het zeker?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: rgbToHex(activity.enrollment_button.css('backgroundColor')),
      confirmButtonText: "Jep!",
      cancelButtonText: "Nee",
      closeOnConfirm: false
    },
    // on confirm
    function () {
      if (activity.has_un_enroll_date_passed())
        confirm_un_enroll_date_passed(activity);
      else {
        swal.close();
        activity.enroll();
      }
    }
  );
}

function confirm_un_enroll_date_passed(activity) {
  swal({
      title: "De uitschrijfdeadline voor deze activiteit is verstreken. Hierdoor is uitschrijven niet mogelijk. Weet je zeker dat je je wilt inschrijven?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: rgbToHex(activity.enrollment_button.css('backgroundColor')),
      confirmButtonText: "Jep!",
      cancelButtonText: "Nee"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.enroll();
    }
  );
}

function confirm_un_enroll(activity) {
  if (activity.has_un_enroll_date_passed()) {
    swal('Uitschrijven mislukt!', 'De uitschrijfdeadline is al verstreken.', 'error');
    return;
  }

  swal({
      title: "Je schrijft je uit voor deze activiteit. Weet je het zeker?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: rgbToHex(activity.enrollment_button.css('backgroundColor')),
      confirmButtonText: "Jep!",
      cancelButtonText: "Nee"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.un_enroll();
    }
  );
}

function confirm_update(activity) {
  swal({
      title: "Weet je zeker dat je deze informatie wilt bewerken?",
      type: "info",
      showCancelButton: true,
      confirmButtonColor: rgbToHex(activity.update_notes_button.css('backgroundColor')),
      confirmButtonText: "Jep!",
      cancelButtonText: "Nee"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.edit_enroll();
    }
  );
}

/**
 * Loads the previous activity to the modal
 */
function prev_poster() {
  modal.activity_data.current.prev_activity.load_data_to_modal();
}


/**
 * Loads the next activity to the modal
 */
function next_poster() {
  modal.activity_data.current.next_activity.load_data_to_modal();
}

function initialize_ui(){
  $(document).ready(function(){
    $('[data-toggle="popover"]').popover();
  });
}

/**
 * Binds the enrollment events
 */
function initialize_enrollment() {
  activity_container = $('#activity-container');

  activity_container.find('button.enrollment').on('click', function () {
    var activity = new Activity($(this).closest('.panel-activity'));
    if (activity.is_enrollable()) {
      if(activity.has_notes() && !activity.are_notes_filled())
        swal("Je hebt geen notities ingevuld!", "Vul ze in op de meer info pagina.", "error");
      else
        confirm_enroll(activity);
    }else
      confirm_un_enroll(activity);
  });

  activity_container.find('button.update-enrollment').on('click', function(){
    var activity = new Activity($(this).closest('.panel-activity'));
    confirm_update(activity);
  });
}

/**
 * Binds the modal events.
 */
function initialize_modal() {
  modal = $('#poster-modal');

  modal.activity_data = {
    img: modal.find('img')
    , title: modal.find('.activity-title')
    , more_info_link: modal.find('.more-info')
  };

  //Add event handler to poster to show the modal
  $(".show-poster-modal").on("click", function () {
    var activity = new Activity($(this).closest('.panel-activity'));
    activity.load_data_to_modal();

    modal.modal('show');
  });

//Add event handler to go to the previous activity in the modal
  $("#prev-poster").on("click", prev_poster);

//Add event handler to go to the next activity in the modal
  $("#next-poster").on("click", next_poster);
}

/**
 * Register all click handlers for enrollments
 */
$(document).on('ready page:load', function () {
  token = encodeURIComponent($(this).find('.page').attr('data-authenticity-token'));

  initialize_ui();
  initialize_enrollment();
  initialize_modal();
});
