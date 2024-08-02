import Swal from "sweetalert2";
import $ from "jquery";
import Clipboard from "clipboard";

import { Poster_modal } from "./poster_modal";
import I18n from "../../translations.js";

import { Activity } from "./activity.js";

var token, modal;

function copyICSToClipboard() {
  new Clipboard("#copy-btn", {
    text: function () {
      return "https://calendar.google.com/calendar/ical/stickyutrecht.nl_thvhicj5ijouaacp1elsv1hceo%40group.calendar.google.com/public/basic.ics";
    },
  });
}

function copyPersonalICSToClipboard() {
  fetch("/api/calendar/fetch")
    .then((response) => response.text())
    .then((icsFeed) => {
      new Clipboard("#copy-btn-personal", {
        text: function () {
          return icsFeed;
        },
      });
    }).catch((error) => {
      console.log(error)
    });
} // TODO makes an API call even if the button is not pressed

export function get_activity_container() {
  return $("#activity-container");
}

/** TODO WHY?
 * Converts a string with format rgb(int, int, int) to hex value
 * @param rgb
 * @returns {string}
 */
function rgbToHex(rgb) {
  var parts = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
  delete parts[0];
  for (var i = 1; i <= 3; ++i) {
    parts[i] = parseInt(parts[i]).toString(16);
    if (parts[i].length === 1) parts[i] = "0" + parts[i];
  }
  return "#" + parts.join("");
}

function confirm_enroll(activity) {
  Swal.fire({
    title: I18n.t("members.activities.actions.enroll"),
    text: I18n.t("members.activities.actions.confirm_enroll"),
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: rgbToHex(
      activity.enrollment_button.css("backgroundColor"),
    ),
    confirmButtonText: I18n.t("members.activities.actions.confirm"),
    cancelButtonText: I18n.t("members.activities.actions.cancel"),
  }).then(
    // on confirm
    function (result) {
      if (result.value) {
        if (activity.has_un_enroll_date_passed())
          confirm_un_enroll_date_passed(activity);
        else {
          activity.enroll();
        }
      }
    },
  );
}

function confirm_un_enroll_date_passed(activity) {
  Swal.fire({
    title: I18n.t("members.activities.actions.enroll"),
    text: I18n.t("members.activities.actions.confirm_enroll_date_passed"),
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: rgbToHex(
      activity.enrollment_button.css("backgroundColor"),
    ),
    confirmButtonText: I18n.t("members.activities.actions.confirm"),
    cancelButtonText: I18n.t("members.activities.actions.cancel"),
  }).then(
    // on confirm
    function (result) {
      if (result.value) activity.enroll();
    },
  );
}

function confirm_un_enroll(activity) {
  if (activity.has_un_enroll_date_passed() && !activity.is_reservist()) {
    Swal.fire(
      I18n.t("members.activities.error.unenroll_failed"),
      I18n.t("members.activities.error.unenroll_deadline"),
      "error",
    );
    return;
  }

  Swal.fire({
    title: I18n.t("members.activities.actions.unenroll"),
    text: I18n.t("members.activities.actions.confirm_unenroll"),
    icon: "warning",
    showCancelButton: true,
    confirmButtonColor: rgbToHex(
      activity.enrollment_button.css("backgroundColor"),
    ),
    confirmButtonText: I18n.t("members.activities.actions.confirm"),
    cancelButtonText: I18n.t("members.activities.actions.cancel"),
  }).then(
    // anonymous function, because this is set to the sweetalert
    function (result) {
      if (result.value) activity.un_enroll();
    },
  );
}

function confirm_update(activity) {
  Swal.fire({
    title: I18n.t("members.activities.actions.confirm_update"),
    icon: "info",
    showCancelButton: true,
    confirmButtonColor: rgbToHex(
      activity.update_notes_button.css("backgroundColor"),
    ),
    confirmButtonText: I18n.t("members.activities.actions.confirm"),
    cancelButtonText: I18n.t("members.activities.actions.cancel"),
  }).then(
    // anonymous function, because this is set to the sweetalert
    function (result) {
      if (result.value) activity.edit_enroll();
    },
  );
}

function initialize_ui() {
  $(document).ready(function () {
    $('[data-toggle="popover"]').popover();
  });
}

/**
 * Binds the enrollment events
 */
function initialize_enrollment() {
  var activity_container = get_activity_container();
  var view = activity_container.data("view");

  activity_container.find("button.enrollment").on("click", function () {
    var activity = new Activity($(this).closest(".panel-activity"), token);
    if (activity.is_enrollable()) {
      if (
        activity.notes_mandatory &&
        !activity.are_notes_filled() &&
        view === "index"
      ) {
        window.location.href += "/" + activity.id;
      } else confirm_enroll(activity);
    } else confirm_un_enroll(activity);
  });

  activity_container.find("button.update-enrollment").on("click", function () {
    var activity = new Activity($(this).closest(".panel-activity"), token);
    confirm_update(activity);
  });
}

/**
 * Binds the modal events.
 */
function initialize_modal() {
  var posterModal = $("#poster-modal");
  //Add event handler to poster to show the modal
  posterModal.on("show.bs.modal", function (event) {
    var activity = new Activity(
      $(event.relatedTarget).closest(".panel-activity"),
      token,
    );
    modal = new Poster_modal(this, activity);
  });

  //Add event handler to go to the previous activity in the modal
  posterModal.find(".prev-activity").on(
    "click",
    /**
     * Loads the previous activity to the modal
     */
    function () {
      modal.prevActivity();
    },
  );

  //Add event handler to go to the next activity in the modal
  posterModal.find(".next-activity").on(
    "click",
    /**
     * Loads the next activity to the modal
     */
    function () {
      modal.nextActivity();
    },
  );

  posterModal.find(".more-info").on("click", function () {
    window.location = modal.current_activity.more_info_href;
  });
}

function equalheight(container) {
  var currentTallest = 0,
    currentRowStart = 0,
    rowDivs = new Array(),
    $el,
    topPosition = 0;

  $(container).each(function () {
    $el = $(this);
    $($el).height("auto");
    topPostion = $el.position().top;

    if (currentRowStart != topPostion) {
      for (currentDiv = 0; currentDiv < rowDivs.length; currentDiv++) {
        rowDivs[currentDiv].height(currentTallest);
      }
      rowDivs.length = 0; // empty the array
      currentRowStart = topPostion;
      currentTallest = $el.height();
      rowDivs.push($el);
    } else {
      rowDivs.push($el);
      currentTallest = Math.max(currentTallest, $el.height()); // (currentTallest < $el.height()) ? ($el.height()) : (currentTallest);
    }
    for (currentDiv = 0; currentDiv < rowDivs.length; currentDiv++) {
      rowDivs[currentDiv].height(currentTallest);
    }
  });
}

/**
 * Register all click handlers for activities
 */
$(document).on("ready page:load turbolinks:load", function () {
  token = encodeURIComponent(
    $(this).find(".page").attr("data-authenticity-token"),
  );

  initialize_ui();
  initialize_enrollment();
  initialize_modal();
  copyICSToClipboard();
  copyPersonalICSToClipboard();
});

document.addEventListener("turbolinks:load", function () {
  equalheight(".sameheight");
});

$(window).on("resize", function () {
  equalheight(".sameheight");
});
