/**
 * @file dropdown.js
 * Dropdown functionality for usage in the bootstrap framework.
 *
 * @author Martijn Casteel
 */

(function($) {
  $.fn.search = function(options) {
    var opts = $.extend({}, $.fn.search.defaults, options);
    var thread = null;

    return this.each(function() {
      $(this).on("focusout", function() {
        $("ul.dropdown-menu").hide(1);
      });

      $(this).on("keydown", function(event) {
        var events = $(this);

        if (event.keyCode == 13) event.preventDefault();

        if (event.keyCode == 9) {
          // trigger selected for [TAB]
          if (
            $(this)
              .next(opts.dropdown)
              .find("li.active").length == 1
          ) {
            $(events).trigger(
              "selected",
              $.fn.search.retrieve(
                $(this)
                  .next(opts.dropdown)
                  .find("li.active")
                  .find("a")
              )
            );

            $("ul.dropdown-menu")
              .delay(10)
              .hide(1);
            $(this)
              .next(opts.dropdown)
              .empty();
          }

          event.preventDefault();
        }
      });

      $(this).on("selected", function() {
        $(this)
          .val("")
          .focus();
      });

      $(this).on("focusin keyup", function(event) {
        var events = $(this);
        var dropdown = $(this).next(opts.dropdown);
        var selected = $(dropdown).find("li.active");

        if (event.keyCode == 13) {
          if ($(selected).length != 1) return;

          $(events).trigger(
            "selected",
            $.fn.search.retrieve($(selected).find("a"))
          );
          $(dropdown)
            .hide()
            .empty();

          event.preventDefault();
        } else if (event.keyCode == 40) {
          $(selected).removeClass("active");
          selected = $(selected).next();

          if ($(selected).length == 0) selected = $(dropdown).find("li:first");

          $(selected).addClass("active");

          event.preventDefault();
        } else if (event.keyCode == 38) {
          $(selected).removeClass("active");
          selected = $(selected).prev();

          if ($(selected).length == 0) selected = $(dropdown).find("li:last");
          $(selected).addClass("active");

          event.preventDefault();
        } else if (opts.minlength <= events.val().length) {
          var data = $.extend(
            {},
            {
              search: events.val()
            },
            opts.query
          );

          clearTimeout(thread);
          thread = setTimeout(function() {
            $.ajax({
              url: opts.source,
              type: "GET",
              data: data
            }).done(function(data) {
              $(dropdown).empty();

              for (var item in data) {
                if (typeof data[item] != "object") continue;

                var html = $.fn.search.format(data[item]);
                $(dropdown).append("<li>" + html + "</li>");
              }

              // add hover to select
              $(dropdown)
                .find("li")
                .on("mouseenter", function() {
                  $(dropdown)
                    .find("li.active")
                    .removeClass("active");
                  selected = $(this).addClass("active");
                });

              // add click event
              $(dropdown)
                .find("li a")
                .on("mousedown", function() {
                  $(events).trigger("selected", $.fn.search.retrieve($(this)));

                  $("ul.dropdown-menu")
                    .delay(10)
                    .hide(1)
                    .empty();
                });

              //show list
              $(dropdown).show();
            });
          }, opts.timeout);
        }
      });
    });
  };

  // override for different format
  $.fn.search.format = function(member) {
    if (!member.infix)
      return (
        "<a data-id=" +
        member.id +
        ">" +
        member.first_name +
        " " +
        member.last_name +
        "</a>"
      );
    return (
      "<a data-id=" +
      member.id +
      ">" +
      member.first_name +
      " " +
      member.infix +
      " " +
      member.last_name +
      "</a>"
    );
  };

  // override if format is changed
  $.fn.search.retrieve = function(member) {
    return [$(member).attr("data-id"), $(member).html()];
  };

  $.fn.search.defaults = {
    minlength: 2,
    timeout: 250,
    source: "/members/search",
    dropdown: "ul.dropdown-menu"
  };
})(jQuery);
