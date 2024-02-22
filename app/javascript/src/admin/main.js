import $ from "jquery";
import I18n from "../translations.js";

$(document).on("ready page:load turbolinks:load", function () {
  // Alerts for on the frontend, default type is info
  // script#alert is a template in de header file.
  String.prototype.format = function () {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function (match, number) {
      return typeof args[number] != "undefined" ? args[number] : match;
    });
  };

  $(".button.btn[data-method=delete]").on("click", function () {
    return confirm(I18n.t("admin.general.confirmation"));
  });

  $(window).on("keydown", (evt) => {
    if (evt.target.type === "input") {
      return;
    }

    // Select the search bar on '/'
    if (evt.key === "s" || evt.key === "/") {
      evt.preventDefault();

      $("#search")?.focus();
    }
  });

  $(".page.search .input-group ul.dropdown-menu")
    .find("li")
    .on("mouseenter", function () {
      $(".page.search .input-group ul.dropdown-menu")
        .find("li.active")
        .removeClass("active");
      $(this).addClass("active");
    })
    .on("mousedown", function () {
      var query = $(".page.search .input-group ul.dropdown-menu:visible").attr(
        "data-query",
      );

      $(".page.search .input-group input[name=search]").val(
        $(".page.search .input-group input[name=search]")
          .val()
          .replace(
            query,
            query.split(":")[0] +
              ":" +
              $(this).find("a").attr("data-name") +
              " ",
          ),
      );

      $("ul.dropdown-menu").removeAttr("data-query").delay(10).hide(1);
      $(".page.search .input-group input[name=search]").focus();
    });

  $(".page.search .input-group")
    .find("input[name=search]")
    .on("click focus keydown keyup", function (event) {
      var study = /(studie|study):([A-Za-z-]*)/g.exec($(this).val());
      var tag = /(tag):([A-Za-z-]*)/g.exec($(this).val());
      var state = /(status|state):([A-Za-z]*)/g.exec($(this).val());

      var dropdown, selected;

      if (
        study !== null &&
        this.selectionStart >= study.index &&
        this.selectionStart <= study.index + study[0].length
      ) {
        dropdown = $(".page.search .input-group").find(
          "ul.dropdown-menu[name=studies]",
        );
        selected = $(
          ".page.search .input-group ul.dropdown-menu[name=studies]",
        ).find("li.active");
        $(dropdown).show();
      } else {
        study = null;
        $("ul.dropdown-menu[name=studies]").delay(10).hide(1);
      }

      if (
        tag !== null &&
        this.selectionStart >= tag.index &&
        this.selectionStart <= tag.index + tag[0].length
      ) {
        dropdown = $(".page.search .input-group").find(
          "ul.dropdown-menu[name=tags]",
        );
        selected = $(
          ".page.search .input-group ul.dropdown-menu[name=tags]",
        ).find("li.active");
        $(dropdown).show();
      } else {
        tag = null;
        $("ul.dropdown-menu[name=tags]").delay(10).hide(1);
      }

      if (
        state !== null &&
        this.selectionStart >= state.index &&
        this.selectionStart <= state.index + state[0].length
      ) {
        dropdown = $(".page.search .input-group").find(
          "ul.dropdown-menu[name=states]",
        );
        selected = $(
          ".page.search .input-group ul.dropdown-menu[name=states]",
        ).find("li.active");
        $(dropdown).show();
      } else {
        state = null;
        $("ul.dropdown-menu[name=states]").delay(10).hide(1);
      }

      //$( dropdown ).css('left', study.index * 6 + 'px');

      if (study !== null) $(dropdown).attr("data-query", study[0]);
      if (tag !== null) $(dropdown).attr("data-query", tag[0]);
      if (state !== null) $(dropdown).attr("data-query", state[0]);

      if (event.keyCode == 13 || event.keyCode == 9) {
        if ($("ul.dropdown-menu:visible").length > 0) event.preventDefault();

        if ($(selected).length != 1) return;

        if (study !== null)
          $(this).val(
            $(this)
              .val()
              .replace(
                study[0],
                study[1] + ":" + $(selected).find("a").attr("data-name") + " ",
              ),
          );
        else if (tag !== null)
          $(this).val(
            $(this)
              .val()
              .replace(
                tag[0],
                tag[1] + ":" + $(selected).find("a").attr("data-name") + " ",
              ),
          );
        else if (state !== null)
          $(this).val(
            $(this)
              .val()
              .replace(
                state[0],
                state[1] + ":" + $(selected).find("a").attr("data-name") + " ",
              ),
          );

        $("ul.dropdown-menu").removeAttr("data-query").delay(10).hide(1);
        $(".page.search .input-group input[name=search]").focus();
      } else if (event.keyCode == 40 && event.type != "keyup") {
        $(selected).removeClass("active");
        selected = $(selected).next();

        if ($(selected).length === 0) selected = $(dropdown).find("li:first");
        $(selected).addClass("active");

        event.preventDefault();
      } else if (event.keyCode == 38 && event.type != "keyup") {
        $(selected).removeClass("active");
        selected = $(selected).prev();

        if ($(selected).length === 0) selected = $(dropdown).find("li:last");
        $(selected).addClass("active");

        event.preventDefault();
      } else if (
        study !== null &&
        event.type != "keyup" &&
        event.keyCode != 8
      ) {
        var items = $.unique(
          $(
            ".page.search .input-group ul.dropdown-menu[name=studies] li a[data-name!=" +
              study[2] +
              "][data-name^=" +
              study[2] +
              "], .page.search .input-group ul.dropdown-menu[name=studies] li a[data-code!=" +
              study[2] +
              "][data-code^=" +
              study[2] +
              "]",
          ),
        );

        if ($(items).length != 1) return;

        $(
          ".page.search .input-group ul.dropdown-menu[name=studies] li",
        ).removeClass("active");
        $(items).parent("li").addClass("active");
      } else if (tag !== null && event.type != "keyup" && event.keyCode != 8) {
        var items = $(
          ".page.search .input-group ul.dropdown-menu[name=tags] li a[data-name!=" +
            tag[2] +
            "][data-name^=" +
            tag[2] +
            "]",
        );

        if ($(items).length != 1) return;

        $(
          ".page.search .input-group ul.dropdown-menu[name=tags] li",
        ).removeClass("active");
        $(items).parent("li").addClass("active");
      } else if (
        state !== null &&
        event.type != "keyup" &&
        event.keyCode != 8
      ) {
        var items = $(
          ".page.search .input-group ul.dropdown-menu[name=states] li a[data-name!=" +
            state[2] +
            "][data-name^=" +
            state[2] +
            "]",
        );

        if ($(items).length != 1) return;

        $(
          ".page.search .input-group ul.dropdown-menu[name=states] li",
        ).removeClass("active");
        $(items).parent("li").addClass("active");
      }
    })
    .on("focusout", function () {
      $(".page.search .input-group").find("ul.dropdown-menu").hide(1);
    });

  $("footer.table-footer .page-num-info select").bind("change", function () {
    var params = {},
      limit = $(this).val();
    $("footer.table-footer .page-num-info").attr("data-limit", limit);

    if ($("footer.table-footer .page-num-info").attr("data-search")) {
      params.search = $("footer.table-footer .page-num-info").attr(
        "data-search",
      );
    }

    params.limit = limit;
    location.search = $.param(params);
  });

  //menu navigation
  $(".toggle-min").click(function (event) {
    event.preventDefault();

    $("#app").children("div").toggleClass("nav-min");
  });

  $(".year select").on("change", function () {
    var params = {};

    params.year = $(this).val();
    location.search = $.param(params);
  });
});
