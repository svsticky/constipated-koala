//= require sweetalert

//TODO unify get next and prev with get sibling
//TODO jquery plugins for modal and activity
//TODO modal class
//TODO poster nav button hide/show to modol class
//TODO more info page

var token, modal, activity_container;

function find_in_object(object, checkFunction) {
  for (var p in object) {
    if (object.hasOwnProperty(p) && checkFunction(object[p]))
      return object[p];
  }
}

function batch_edit_properties(obj, edit_function) {
  Object.keys(obj).forEach(function (key) {
    obj[key] = edit_function(key, obj[key], obj);
  });

  return obj;
}

var cached_prefix = '_cached_';

function get_cached_loader(load_function, cache_name) {
  return function () {
    if (typeof this[cache_name] === 'undefined')
      return this[cache_name] = load_function.call(this);
    else
      return this[cache_name];
  };
}

function get_cached_writer(write_function, cache_name) {
  return function (value) {
    write_function.call(this, value);
    this[cache_name] = value;
  };
}

function init_cached_properties(obj, props) {
  batch_edit_properties(props, function (name, descriptor, obj) {
    var cache_name = cached_prefix + name;
    if (typeof descriptor === 'function') {
      descriptor.get = get_cached_loader(descriptor, cache_name);
    } else if (typeof descriptor === 'object') {
      descriptor.get = get_cached_loader(descriptor.load, cache_name);

      if (descriptor.write)
        descriptor.set = get_cached_writer(descriptor.write, cache_name);
    }

    obj[cache_name] = {};

    return descriptor;
  });

  obj.delete_cache = function (property) {
    delete this[cached_prefix + property];
  };

  return props;
}

function updateParticipantsList(activity_id) {
  var attendeesTable = $('#attendees');
  var reservistsTable = $('#reservists');

  if (attendeesTable.length == 0)
    return;

  $.ajax('/api/activities/' + activity_id).done(function (activity) {
    attendeesTable.html('');
    activity.attendees.forEach(function (name) {
      attendeesTable.append('<tr><td>' + name + '</td></tr>');
    });

    reservistsTable.html('');
    activity.reservists.forEach(function (name) {
      reservistsTable.append('<tr><td>' + name + '</td></tr>');
    });

    $('#attendees-count').html(activity.attendees.length);
    $('#reservists-count').html(activity.reservists.length)
  });
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
      activity._enrollment_status = Enrollment_stati.un_enrolled;
    });
  },

  has_un_enroll_date_passed: function () {
    return typeof this.un_enroll_date !== 'undefined' && $.now() > this.un_enroll_date;
  },

  is_enrollable: function () {
    return this.enrollment_status === Enrollment_stati.un_enrolled;
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
      this.fullness_display.text();
    },
    set: function (value) {
      this.fullness_display.text(value);
    }
  },

  _participant_count: {
    get: function () {
      Activity.get_participant_count_from_string(this._fullness);
    },
    set: function (value) {
      this.attendee_count_display.html(value);
    }
  },

  _reservist_count: {
    get: function () {
      this.reservist_count_display.html();
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
            .removeClass(this._enrollment_status.identifying_class)
            .addClass(enrollment_status.identifying_class)
            .text(enrollment_status.buttonText);
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
  , reservist: new Enrollment_status('btn-warning', 'Reservelijst')
};

function Enrollment_status(identifying_class, buttonText) {
  this.identifying_class = identifying_class;
  this.buttonText = buttonText;
}

Enrollment_status.fromButton = function (button) {
  return find_in_object(Enrollment_stati, function (enrollment_status) {
    return button.hasClass(enrollment_status.identifying_class);
  });
};

function confirm_enroll(activity) {
  swal({
      title: "Je wordt ingeschreven voor deze activiteit. Weet je het zeker?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "Jep!",
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
      title: "De uitschrijfdeadline voor deze activiteit is verstreken. Je inschrijving kan dus niet ongedaan gemaakt worden. Weet je heel zeker dat je je wilt inschrijven?",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "Jep!"
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
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "Jep!"
    }
    // anonymous function, because this is set to the sweetalert
    , function () {
      activity.un_enroll();
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

function initialize_enrollment() {
  activity_container = $('#activity-container');

  $('#enrollments').find('button.enrollment').on('click', function () {
    var activity = new Activity($(this).closest('.panel-activity'));
    if (activity.is_enrollable())
      confirm_enroll(activity);
    else
      confirm_un_enroll(activity);
  });
}

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

  initialize_enrollment();
  initialize_modal();
});