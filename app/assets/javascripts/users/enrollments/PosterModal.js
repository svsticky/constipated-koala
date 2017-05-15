//= require users/enrollments/cacheHelpers

function Poster_modal(element, activity) {
  this.element = $(element);
  this.load_activity_data(activity);
}

Poster_modal.prototype = {
  load_activity_data: function (activity) {
    this.current_activity = activity;

    //Load the poster of the panel activity in the modal
    this.img.attr('src',
      activity.poster_source.replace('thumb', 'medium'));

    //set the more info href
    if(!inMoreInfoView())
      this.more_info.attr('href', activity.more_info_href);

    //Load the title of the panel activity in the modal
    this.title.html(activity.title);

    this.activityId = activity.id;

    //Check if there are previous activities to go to
    if (activity.is_first())
      this.prevButton.css("display", "none");
    else
      this.prevButton.css("display", "inline-block");

    //Check if there are any next activities to go to
    if (activity.is_last())
      this.nextButton.css("display", "none");
    else
      this.nextButton.css("display", "inline-block");
  },

  nextActivity: function () {
    this.load_activity_data(this.current_activity.next_activity);
  },

  prevActivity: function () {
    this.load_activity_data(this.current_activity.prev_activity);
  }
};

Object.defineProperties(Poster_modal.prototype, batch_edit_properties({
  activityId: {
    get: function () {
      return this.element.attr("data-activity-id");
    },
    set: function (value) {
      this.element.attr("data-activity-id", value);
    }
  }
  }, function (name, descriptor) {
    descriptor.enumerable = true;
    return descriptor;
  })
);

Object.defineProperties(Poster_modal.prototype,
  init_cached_properties(Poster_modal.prototype, {
    img: function () {
      return this.element.find('img');
    },
    title: function () {
      return this.element.find('.activity-title');
    },
    more_info: function () {
      return this.element.find('.more-info');
    },
    nextButton: function () {
      return this.element.find('.next-activity');
    },
    prevButton: function () {
      return this.element.find('.prev-activity');
    }
  })
);
