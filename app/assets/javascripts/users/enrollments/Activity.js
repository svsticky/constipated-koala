//= require cacheHelpers

/**
 * Checks if an object has a property that satisfies the checkfuntion.
 * @param object
 * @param checkFunction
 * @returns {*}
 */
function find_in_object(object, checkFunction) {
  for (var p in object) {
    if (object.hasOwnProperty(p) && checkFunction(object[p]))
      return object[p];
  }
}

/**
 * Activity constructor
 * @param activity_panel The panel frim which to create the activity
 * @constructor
 */
function Activity(activity_panel) {
  this.panel = activity_panel;
}

Activity.full_string = 'VOL!';

Activity.get_participant_count_from_string = function (fullness) {
  if (!fullness.includes(Activity.full_string))
    return fullness.match(/\d+/)[0];
};

Activity.get_participant_limit_from_string = function (fullness) {
  if (!fullness.includes(Activity.full_string)) {
    var numbers = fullness.match(/\d+/);
    if (typeof numbers[1] !== 'undefined')
      return numbers[1];
  }
};

Activity.get_fullness_from_count_and_limit = function (count, limit) {
  if (limit === null)
    return '' + count;
  else if (count >= limit)
    return Activity.full_string;
  else
    return count + ' / ' + limit;
};

Activity.prototype = {
  get_panel_selector: function () {
    return '.panel-activity[data-activity-id=' + this.id + ']';
  },

  /**
   * Enroll the current user for this Activity.
   * @returns jqXHR
   */
  enroll: function () {
    var activity = this;
    var request = this._remote_update_enrollment('POST').done(function () {
      //Normal enrollment
      if (request.status == 200) {
        activity._enrollment_status = Enrollment_stati.enrolled;
        //Back-up list enrollments
      } else if (request.status == 202) {
        activity._enrollment_status = Enrollment_stati.reservist;
      }

      activity.update_notes_button.removeClass('hide');
    });

    return request;
  },

  /**
   * Unenroll the current user for this Activity.
   * @returns jqXHR
   */
  un_enroll: function () {
    var activity = this;
    return this._remote_update_enrollment('DELETE').done(function () {
      if (activity._fullness == Activity.full_string) {
        activity._enrollment_status = Enrollment_stati.reservistable;
      }
      else {
        activity._enrollment_status = Enrollment_stati.un_enrolled;
      }

      activity.update_notes_button.addClass('hide');
    });
  },

  /**
   * Updates the enrollment of the current user for this Activity.
   * @returns jqXHR
   */
  edit_enroll: function () {
    return this._remote_update_enrollment('PATCH');
  },

  has_un_enroll_date_passed: function () {
    return typeof this.un_enroll_date !== 'undefined' && $.now() > this.un_enroll_date;
  },

  is_enrollable: function () {
    return this.enrollment_status === Enrollment_stati.un_enrolled || this.enrollment_status === Enrollment_stati.reservistable;
  },

  has_notes: function () {
    return this.notes.length !== 0;
  },

  are_notes_filled: function () {
    return ($.trim(this.notes.val()).length > 0);
  },

  /**
   * Returns if this is the first activity in the view.
   * @returns {boolean}
   */
  is_first: function () {
    return typeof this.prev_activity === 'undefined';
  },

  /**
   * Returns if this is the last activity in the view.
   * @returns {boolean}
   */
  is_last: function () {
    return typeof this.next_activity === 'undefined';
  }
};

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
    }
  },

  _participant_count: {
    get: function () {
      return Activity.get_participant_count_from_string(this._fullness);
    },
    set: function (value) {
      this.attendee_count_display.html(value);
    }
  },

  _reservist_count: {
    get: function () {
      return this.reservist_count_display.html();
    },
    set: function (value) {
      this.reservist_count_display.html(value);
    }
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
        url: '/enrollments/' + activity.id,
        type: method,
        data: {
          authenticity_token: token,
          par_notes: this.notes.val()
        }
      }).done(function (response) {
        //Alert user of  enrollment
        alert(response.message, 'success');

        activity._fullness = Activity.get_fullness_from_count_and_limit(response.participant_count,
          response.participant_limit);
      }).fail(function (data) {
        var message;
        switch (method) {
          case "POST":
            message = "Kon niet inschrijven!\n";
            break;
          case "DELETE":
            message = "Kon niet uitschrijven!\n";
            break;
          case "PATCH":
            message = "Kon niet bijwerken!\n";
            break;
        }
        if (data.responseJSON) {
          message += data.responseJSON.message;
        }
        alert(message, 'error');
      });

      if (this.attendees_table.length == 0)
        return request;
      else
        return request.done(function () {
          $.ajax('/api/activities/' + activity.id).done(function (response) {
            activity.attendees_table.html('');
            response.attendees.forEach(function (name) {
              activity.attendees_table.append('<tr><td>' + name + '</td></tr>');
            });

            activity.reservists_table.html('');
            response.reservists.forEach(function (name) {
              activity.reservists_table.append('<tr><td>' + name + '</td></tr>');
            });

            activity._participant_count = response.attendees.length;
            activity._reservist_count = response.reservists.length;
          });
        });
    }
  }
});

/**
 * Public properties
 */
Object.defineProperties(Activity.prototype, batch_edit_properties({
    enrollment_status: {
      get: function () {
        return this._enrollment_status;
      }
    },

    participant_count: {
      get: function () {
        return this._participant_count;
      }
    },

    participant_limit: {
      get: function () {
        Activity.get_participant_limit_from_string(this._fullness);
      }
    },

    /**
     * The text that denotes how full the activity is.
     * Possible values: Vol!, <participantCount> or <participantCount>/<participantLimit>
     */
    fullness: {
      get: function () {
        return this._fullness;
      }
    },

    /**
     * The div which is a child of activity_container and of which the panel of this activity is a child.
     */
    corresponding_activity_container_child: {
      get: function () {
        return get_activity_container().children(':has(' + this.get_panel_selector() + ')');
      }
    },

    next_activity: {
      get: function () {
        var next = this.corresponding_activity_container_child.next().find('.panel-activity');
        if (next.length !== 0)
          return new Activity(next);
        else
          return undefined;
      }
    },

    prev_activity: {
      get: function () {
        var prev = this.corresponding_activity_container_child.prev().find('.panel-activity');
        if (prev.length !== 0)
          return new Activity(prev);
        else
          return undefined;
      }
    }
  }, function (name, descriptor) {
    descriptor.enumerable = true;
    return descriptor;
  })
);

/**
 * Public cached properties
 */
Object.defineProperties(Activity.prototype,
  init_cached_properties(Activity.prototype, {
    id: function () {
      return parseInt(this.panel.attr('data-activity-id'));
    },

    enrollment_button: function () {
      return this.panel.find('button.enrollment');
    },

    un_enroll_date: function () {
      var date_unsplit = this.panel.find('.activity-unenroll')[0];
      if (typeof date_unsplit !== "undefined") {
        var date_split = date_unsplit.innerText.split("/");
        return new Date(date_split[2], date_split[1] - 1, date_split[0]);
      }
    },

    poster_source: function () {
      return this.panel.find('.small-poster').attr('src');
    },

    more_info_href: function () {
      return this.panel.find('.more-info').attr('href');
    },

    title: function () {
      return this.panel.find('.activity-title').html();
    },

    notes: function () {
      return this.panel.find('.notes');
    },

    update_notes_button: function () {
      return this.panel.find('.update-enrollment');
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
      }
    },

    /**
     * The span that displays this activity's fullness
     */
    fullness_display: function () {
      return this.panel.find('.activity-count');
    },

    attendees_table: function () {
      return $('#attendees');
    },

    attendee_count_display: function () {
      return $('#attendees-count');
    },

    reservists_table: function () {
      return $('#reservists');
    },

    reservist_count_display: function () {
      return $('#reservists-count');
    }
  })
);

/**
 * Enrollment stati are identified by text.
 * @type {{un_enrolled: Enrollment_status, enrolled: Enrollment_status, reservist: Enrollment_status, reservistable: Enrollment_status}}
 */
var Enrollment_stati = {
  un_enrolled: new Enrollment_status('btn-success', 'Inschrijven')
  , enrolled: new Enrollment_status('btn-danger', 'Uitschrijven')
  , reservist: new Enrollment_status('btn-warning', 'Uitschrijven Reservelijst')
  , reservistable: new Enrollment_status('btn-warning-sat', 'Inschrijven Reservelijst')
};

function Enrollment_status(classes, buttonText) {
  this.classes = classes;
  this.button_text = buttonText;
}

Enrollment_status.fromButton = function (button) {
  var button_text = button.text().trim();
  return find_in_object(Enrollment_stati, function (enrollment_status) {
    return button_text == enrollment_status.button_text;
  });
};
