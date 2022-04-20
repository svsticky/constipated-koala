import Swal from "sweetalert2";
import $ from "jquery";

import {
  batch_edit_properties,
  init_cached_properties,
} from "../../cache_helpers.js";
import "../../language.js";
import I18n from "../../translations.js";
import { get_activity_container } from "./activities";

/**
 * Checks if an object has a property that satisfies the checkfuntion.
 * @param object
 * @param checkFunction
 * @returns {*}
 */
function find_in_object(object, checkFunction) {
  for (var p in object) {
    if (object.hasOwnProperty(p) && checkFunction(object[p])) return object[p];
  }
}

var AlertTitles = {
  POST: I18n.t("members.activities.actions.enroll"),
  PATCH: I18n.t("members.activities.actions.edit"),
  DELETE: I18n.t("members.activities.actions.unenroll"),
};

/**
 * Activity constructor
 * @param activity_panel The panel from which to create the activity
 * @constructor
 */
export class Activity {
  constructor(activity_panel, token = null) {
    this.panel = activity_panel;
    this.token = token;
  }
  static get_participant_count_from_string(fullness) {
    if (!fullness.includes(Activity.full_string))
      return fullness.match(/\d+/)[0];
  }
  static get_participant_limit_from_string(fullness) {
    if (!fullness.includes(Activity.full_string)) {
      var numbers = fullness.match(/\d+/);
      if (typeof numbers[1] !== "undefined") return numbers[1];
    }
  }
  static get_fullness_from_count_and_limit(count, limit) {
    if (limit === null) return "" + count;
    else if (count >= limit) return Activity.full_string;
    else return count + " / " + limit;
  }
  get_panel_selector() {
    return ".panel-activity[data-activity-id=" + this.id + "]";
  }
  /**
   * Enroll the current user for this Activity.
   * @returns jqXHR
   */
  enroll() {
    var activity = this;
    var request = this._remote_update_enrollment("POST").done(function () {
      //Normal enrollment
      if (request.status === 200) {
        activity._enrollment_status = Enrollment_stati.enrolled;
        //Back-up list activities
      } else if (request.status === 202) {
        activity._enrollment_status = Enrollment_stati.reservist;
      }

      activity.update_notes_button.removeClass("d-none");
    });

    return request;
  }
  /**
   * Unenroll the current user for this Activity.
   * @returns jqXHR
   */
  un_enroll() {
    var activity = this;
    return this._remote_update_enrollment("DELETE").done(function () {
      if (activity._fullness === Activity.full_string) {
        activity._enrollment_status = Enrollment_stati.reservistable;
      } else {
        activity._enrollment_status = Enrollment_stati.un_enrolled;
      }

      activity.update_notes_button.addClass("d-none");
    });
  }
  /**
   * Updates the enrollment of the current user for this Activity.
   * @returns jqXHR
   */
  edit_enroll() {
    return this._remote_update_enrollment("PATCH");
  }
  has_un_enroll_date_passed() {
    return (
      typeof this.un_enroll_date !== "undefined" &&
      new Date() > this.un_enroll_date
    );
  }
  is_enrollable() {
    return (
      this.enrollment_status === Enrollment_stati.un_enrolled ||
      this.enrollment_status === Enrollment_stati.reservistable
    );
  }
  has_notes() {
    return this.notes.length !== 0;
  }
  are_notes_filled() {
    return $.trim(this.notes.val()).length > 0;
  }
  /**
   * Returns if this is the first activity in the view.
   * @returns {boolean}
   */
  is_first() {
    return typeof this.prev_activity === "undefined";
  }
  /**
   * Returns if this is the last activity in the view.
   * @returns {boolean}
   */
  is_last() {
    return typeof this.next_activity === "undefined";
  }

  /**
   * Returns whether the current participant is a reservist.
   */
  is_reservist() {
    return this._enrollment_status == Enrollment_stati.reservist;
  }
}

Activity.full_string = I18n.t("members.activities.full");

/**
 * Private properties
 */
Object.defineProperties(Activity.prototype, {
  /**
   * The text that denotes how full the activity is.
   * Possible values: Vol!, <participantCount> or <participantCount>/<participantLimit>
   */
  _fullness: {
    get: function () {
      return this.fullness_display.text().trim();
    },
    set: function (value) {
      this.fullness_display.text(value);
    },
  },

  _participant_count: {
    get: function () {
      return Activity.get_participant_count_from_string(this._fullness);
    },
    set: function (value) {
      this.attendee_count_display.html(value);
    },
  },

  _reservist_count: {
    get: function () {
      return this.reservist_count_display.html();
    },
    set: function (value) {
      this.reservist_count_display.html(value);
    },
  },

  _remote_update_enrollment: {
    /**
     * Send the ajax request to update the enrollment
     * @param method
     * @returns {*}
     */
    value: function (method) {
      var activity = this;
      var request = $.ajax({
        url: "/activities/" + activity.id + "/participants",
        type: method,
        data: {
          authenticity_token: this.token,
          par_notes: this.notes.val(),
        },
      })
        .done(function (response) {
          //Alert user of  enrollment
          Swal.fire({
            title: AlertTitles[method],
            text: response.message,
            timer: 10000,
            icon: "success",
          });

          activity._fullness = Activity.get_fullness_from_count_and_limit(
            response.participant_count,
            response.participant_limit
          );
        })
        .fail(function (data) {
          var message;
          switch (method) {
            case "POST":
              message = I18n.t("members.activities.error.enroll");
              break;
            case "DELETE":
              message = I18n.t("members.activities.error.unenroll");
              break;
            case "PATCH":
              message = I18n.t("members.activities.error.edit");
              break;
          }
          if (data.responseJSON) {
            message += data.responseJSON.message;
          }

          Swal.fire({
            title: AlertTitles[method],
            text: message,
            icon: "error",
          });
        });

      if (this.attendees_table_body.length === 0) return request;
      else
        return request.done(function () {
          $.ajax("/api/activities/" + activity.id).done(function (response) {
            activity.attendees_table_body.html("");
            response.attendees.forEach(function (participant) {
              activity.attendees_table_body.append(
                $("template#participant_table_row_template")
                  .html()
                  .format(
                    participant.name,
                    participant.notes === null ? "" : participant.notes
                  )
              );
            });

            activity.reservists_table_body.html("");
            response.reservists.forEach(function (participant) {
              activity.reservists_table_body.append(
                $("template#participant_table_row_template")
                  .html()
                  .format(
                    participant.name,
                    participant.notes === null ? "" : participant.notes
                  )
              );
            });

            activity._participant_count = response.attendees.length;
            activity._reservist_count = response.reservists.length;
          });
        });
    },
  },
});

/**
 * Public properties
 */
Object.defineProperties(
  Activity.prototype,
  batch_edit_properties(
    {
      enrollment_status: {
        get: function () {
          return this._enrollment_status;
        },
      },

      participant_count: {
        get: function () {
          return this._participant_count;
        },
      },

      participant_limit: {
        get: function () {
          Activity.get_participant_limit_from_string(this._fullness);
        },
      },

      /**
       * The text that denotes how full the activity is.
       * Possible values: Vol!, <participantCount> or <participantCount>/<participantLimit>
       */
      fullness: {
        get: function () {
          return this._fullness;
        },
      },

      /**
       * The div which is a child of activity_container and of which the panel of this activity is a child.
       */
      corresponding_activity_container_child: {
        get: function () {
          return get_activity_container().children(
            ":has(" + this.get_panel_selector() + ")"
          );
        },
      },

      next_activity: {
        get: function () {
          var next = this.corresponding_activity_container_child
            .next()
            .find(".panel-activity");
          if (next.length !== 0) return new Activity(next);
          else return undefined;
        },
      },

      prev_activity: {
        get: function () {
          var prev = this.corresponding_activity_container_child
            .prev()
            .find(".panel-activity");
          if (prev.length !== 0) return new Activity(prev);
          else return undefined;
        },
      },
    },
    function (name, descriptor) {
      descriptor.enumerable = true;
      return descriptor;
    }
  )
);

/**
 * Public cached properties
 */
Object.defineProperties(
  Activity.prototype,
  init_cached_properties(Activity.prototype, {
    id: function () {
      return parseInt(this.panel.data("activity-id"));
    },

    enrollment_button: function () {
      return this.panel.find("button.enrollment");
    },

    un_enroll_date: function () {
      if (typeof this.panel[0].dataset.unenrollDate !== "undefined") {
        var timestamp = Number(this.panel[0].dataset.unenrollDate);
        var result = new Date(timestamp * 1000); // * 1000 is for milliseconds
        return result;
      }
    },

    poster_source: function () {
      return this.panel.find(".small-poster").attr("src");
    },

    more_info_href: function () {
      return this.panel.find(".more-info").attr("href");
    },

    title: function () {
      return this.panel.find(".activity-title").html();
    },

    notes: function () {
      return this.panel.find(".notes");
    },

    notes_mandatory: function () {
      return this.panel.is("[data-notes-mandatory]");
    },

    update_notes_button: function () {
      return this.panel.find(".update-enrollment");
    },

    _enrollment_status: {
      load: function () {
        return Enrollment_status.fromButton(this.enrollment_button);
      },
      write: function (enrollment_status) {
        this.enrollment_button
          .removeClass(this._enrollment_status.classes)
          .addClass(enrollment_status.classes)
          .text(enrollment_status.button_text);
      },
    },

    /**
     * The span that displays this activity's fullness
     */
    fullness_display: function () {
      return this.panel.find(".fullness");
    },

    attendees_table_body: function () {
      return $("#attendees_table").children("tbody");
    },

    attendee_count_display: function () {
      return $("#attendees-count");
    },

    reservists_table_body: function () {
      return $("#reservists_table").children("tbody");
    },

    reservist_count_display: function () {
      return $("#reservists-count");
    },
  })
);

/**
 * Enrollment stati are identified by text.
 * @type {{un_enrolled: Enrollment_status, enrolled: Enrollment_status, reservist: Enrollment_status, reservistable: Enrollment_status}}
 */
var Enrollment_stati = {
  un_enrolled: new Enrollment_status(
    "btn-success",
    I18n.t("members.activities.actions.enroll")
  ),
  enrolled: new Enrollment_status(
    "btn-danger",
    I18n.t("members.activities.actions.unenroll")
  ),
  reservist: new Enrollment_status(
    "btn-warning",
    I18n.t("members.activities.actions.reservist_unenroll")
  ),
  reservistable: new Enrollment_status(
    "btn-warning",
    I18n.t("members.activities.actions.reservist_enroll")
  ),
};

function Enrollment_status(classes, buttonText) {
  this.classes = classes;
  this.button_text = buttonText;
}

Enrollment_status.fromButton = function (button) {
  var button_text = button.text().trim();
  return find_in_object(Enrollment_stati, function (enrollment_status) {
    return button_text === enrollment_status.button_text;
  });
};
