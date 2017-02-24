//= require cacheHelpers

function find_in_object(object, checkFunction) {
  for (var p in object) {
    if (object.hasOwnProperty(p) && checkFunction(object[p]))
      return object[p];
  }
}

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
    return ''+count;
  else if (count >= limit)
    return Activity.full_string;
  else
    return count + ' / ' + limit;
};

Activity.prototype = {
  /**
   * Loads data of a panel-activity to the modal
   */
  load_data_to_modal: function () {
    //Load the poster of the panel activity in the modal
    modal.activity_data.img.attr('src',
      this.poster_source.replace('thumb', 'medium'));

    //set the more info href
    modal.activity_data.more_info_link.attr('href', this.more_info_href);

    //Load the title of the panel activity in the modal
    modal.activity_data.title.html(this.title);

    modal.activity_data.id = this.id;

    modal.activity_data.current = this;

    //Check if there are previous activities to go to
    if (this.is_first())
      $('#prev-poster').css("display", "none");
    else
      $('#prev-poster').css("display", "inline-block");

    //Check if there are any next activities to go to
    if (this.is_last())
      $('#next-poster').css("display", "none");
    else
      $('#next-poster').css("display", "inline-block");
  },

  get_panel_selector: function () {
    return '.panel-activity[data-activity-id=' + this.id + ']';
  },

  enroll: function () {
    var activity = this;
    var request = this._remote_update_enrollment(true).done(function () {
      //Normal enrollment
      if (request.status == 200) {
        activity._enrollment_status = Enrollment_stati.enrolled;
        //Back-up list enrollments
      } else if (request.status == 202) {
        activity._enrollment_status = Enrollment_stati.reservist;
      }
    });


    return request;
  },

  un_enroll: function () {
    var activity = this;
    return this._remote_update_enrollment(false).done(function () {
      if(activity._fullness == Activity.full_string) {
        activity._enrollment_status = Enrollment_stati.reservistable;
      }
      else {
        activity._enrollment_status = Enrollment_stati.un_enrolled;
      }
    });
  },

  has_un_enroll_date_passed: function () {
    return typeof this.un_enroll_date !== 'undefined' && $.now() > this.un_enroll_date;
  },

  is_enrollable: function () {
    return this.enrollment_status === Enrollment_stati.un_enrolled || this.enrollment_status === Enrollment_stati.reservistable;
  },

  has_notes: function(){
    return typeof this.notes !== 'undefined';
  },

  notes_filled: function(){
    return ($.trim($('#enrollment_notes_value').val()).length > 0)
  },

  is_first: get_cached_loader(function () {
    return this.corresponding_activity_container_child.is(':first-child');
  }, cached_prefix + 'is_first'),

  is_last: get_cached_loader(function () {
    return this.corresponding_activity_container_child.is(':last-child');
  }, cached_prefix + 'is_last')
};

Object.defineProperties(Activity.prototype, {
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
    value: function (enrollment) {
      var activity = this;
      var request = $.ajax({
        url: '/enrollments/' + activity.id,
        type: enrollment ? 'POST' : 'DELETE',
        data: {
          authenticity_token: token
        }
      }).done(function (response) {
        //Alert user of  enrollment
        alert(response.message, 'success');

        activity._fullness = Activity.get_fullness_from_count_and_limit(response.participant_count, response.participant_limit);
      }).fail(function (data) {
        var message = enrollment ? 'Kon niet inschrijven!\n' : 'Kon niet uitschrijven!\n';
        if (data.responseJSON) {
          message += data.responseJSON.message;
        }
        alert(message, 'error');
      });

      if (this.attendees_table.length == 0)
        return request;

      $.ajax('/api/activities/' + this.id).done(function (response) {
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

      return request;
    }
  }
});

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

    fullness: {
      get: function () {
        return this._fullness;
      }
    }
  }, function (name, descriptor) {
    descriptor.enumerable = true;
    return descriptor;
  })
);

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

    corresponding_activity_container_child: function () {
      return activity_container.children(':has(' + this.get_panel_selector() + ')');
    },

    fullness_display: function () {
      return this.panel.find('.activity-count');
    },

    next_activity: function () {
      return new Activity(this.corresponding_activity_container_child.next().find('.panel-activity'));
    },

    prev_activity: function () {
      return new Activity(this.corresponding_activity_container_child.prev().find('.panel-activity'));
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

var Enrollment_stati = {
  un_enrolled: new Enrollment_status('btn-success', 'Inschrijven')
  , enrolled: new Enrollment_status('btn-danger', 'Uitschrijven')
  , reservist: new Enrollment_status('btn-warning-sat', 'Unenroll Reservelijst')
  , reservistable: new Enrollment_status('btn-warning', 'Enroll Reservelijst')
};

function Enrollment_status(classes, buttonText) {
  this.classes = classes;
  this.button_text = buttonText;
}

Enrollment_status.fromButton = function (button) {
    var button_text  = button.text().trim();
  return find_in_object(Enrollment_stati, function (enrollment_status) {
    return button_text == enrollment_status.button_text;
  });
};
