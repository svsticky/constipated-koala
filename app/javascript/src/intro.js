import $ from "jquery";
import jQuery from "jquery";
import I18n from "./translations.js";
import { setup_intl_tel_input } from "./intl_tel_number";

$(document).on("ready page:load turbolinks:load", function () {
  var disabledStudyOptions = null;
  var studyBlockers = {
    1: 3,
    3: 1,
  };

  $("#menu-close").on("click", function (e) {
    e.preventDefault();
    $("#sidebar-wrapper").toggleClass("active");
  });

  $(".alert .close").on("click", function () {
    $(this).closest(".alert").remove();
  });

  $("a[href*='#']").on("click", function () {
    if (
      location.pathname.replace(/^\//, "") ==
      this.pathname.replace(/^\//, "") ||
      location.hostname == this.hostname
    ) {
      var target = $(this.hash);
      target = target.length ? target : $("[name=" + this.hash.slice(1) + "]");
      if (target.length) {
        $("html,body").animate(
          {
            scrollTop: target.offset().top,
          },
          1000
        );
        return false;
      }
    }
  });

  jQuery.validator.addMethod(
    "valid_student_id",
    function (value, element) {
      if (/\F\d{6}/.test(value)) {
        return true;
      }
      return true;
    },
    I18n.t("form.invalid_student_id")
  );

  jQuery.validator.addMethod(
    "required_if_minor",
    function (value, element) {
      // get max birth date to be 18 years old, ignoring time
      var maxDate = new Date();
      maxDate.setUTCHours(0, 0, 0, 0);
      maxDate.setFullYear(maxDate.getFullYear() - 18);

      var birthDate = new Date($("#member_birth_date").val());

      // field is valid if member is 18 years or if it's not empty
      return birthDate < maxDate || value;
    },
    I18n.t("form.phone_required_underage")
  );

  $("form").validate({
    rules: {
      "member[first_name]": "required",
      "member[last_name]": "required",
      "member[birth_date]": "required",
      "member[address]": "required",
      "member[house_number]": "required",
      "member[postal_code]": "required",
      "member[city]": "required",
      "member[phone_number]": "required",
      "member[emergency_phone_number]": {
        required_if_minor: true,
      },
      "member[email]": {
        required: true,
        email: true,
      },
      "member[student_id]": {
        required: true,
        valid_student_id: true,
      },
      bank: {
        required: function () {
          return $(".ui-select select#method").val() == "IDEAL";
        },
      },
    },
    errorClass: "invalid",
    errorPlacement: function (error, element) { },
  });

  $("select#method").on("change", function () {
    if ($(this).val() == "Cash/PIN") {
      $("select#bank")
        .attr("disabled", "disabled")
        .css("background-color", "rgb(238, 238, 238)")
        .css("color", "rgb(118, 118, 118)")
        .css("border-color", "rgb(203, 213, 221)");
      $("label#bank").css("color", "rgb(222, 222, 222)");
    } else {
      $("select#bank").removeAttr("disabled").removeAttr("style");
      $("label#bank").removeAttr("style");
    }
  });

  $(".studies select").on("change", function () {
    var selected = $(this).find("option:selected");

    if (selected.data("masters")) {
      $(".activities").hide();
    } else {
      $(".activities").show();
    }

    if (disabledStudyOptions !== null) {
      disabledStudyOptions.prop("disabled", false);
      disabledStudyOptions = null;
    }

    var blockedId = studyBlockers[selected.val()];
    if (typeof blockedId !== "undefined") {
      disabledStudyOptions = $(this)
        .closest(".studies > *")
        .nextAll()
        .find("option[value=" + blockedId + "]");
      disabledStudyOptions.prop("disabled", true);
    }
  });

  setTimeout(function () {
    $(".alert.alert-success").hide();
  }, 3000);

  var jumboHeight = $(".header").outerHeight();

  $(window).on("scroll", function (e) {
    var scrolled = $(window).scrollTop();
    $(".header-bg").css("height", jumboHeight - scrolled + "px");
    $(".header-bg").css("height", jumboHeight - scrolled + "px");
  });

  setup_intl_tel_input();
});
