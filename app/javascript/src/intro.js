import $ from "jquery";
import jQuery from "jquery";
import I18n from "./translations.js";
import { setup_intl_tel_input } from "./intl_tel_number";

$(document).on("ready page:load turbolinks:load", function () {
  setup_popup_close();
  setup_auto_scroll_to_signup_error();
  setup_smooth_scroll();
  setup_form_validation();
  setup_form_payment_method_watcher();
  setup_form_studies_watcher();
  setup_background_parallax();

  setup_intl_tel_input();
});

function setup_popup_close() {
  $("#notice > .popup").on("click", function () {
    $("#notice").fadeOut();
  });
}

function setup_auto_scroll_to_signup_error() {
  const signupErrors = $("#signup-errors");

  if (signupErrors.length > 0) {
    const navbarOffset = $(".navbar").outerHeight();
    const target = $("#enroll");

    $("html,body").animate(
      {
        scrollTop: Math.ceil(Math.max(target.offset().top - navbarOffset, 0)),
      },
      1000,
    );
  }
}

function setup_smooth_scroll() {
  $("a[href*='#']").on("click", function () {
    if (
      location.pathname.replace(/^\//, "") ===
        this.pathname.replace(/^\//, "") ||
      location.hostname === this.hostname
    ) {
      const target = $(`${this.hash}, [name=${this.hash.slice(1)}]`);

      if (target.length > 0) {
        const navbarOffset = $(".navbar").outerHeight();

        $("html,body").animate(
          {
            scrollTop: Math.ceil(
              Math.max(target.offset().top - navbarOffset, 0),
            ),
          },
          1000,
        );
        return false;
      }
    }
  });
}

function setup_background_parallax() {
  let jumboHeight = $(window).height();
  const headerBackground = $(".header-bg");

  $(window).on("resize", function () {
    jumboHeight = $(window).height();
  });

  $(window).on("scroll resize", function () {
    const scrolled = $(window).scrollTop();
    headerBackground.css("height", jumboHeight - scrolled + "px");
  });
}

function setup_form_validation() {
  jQuery.validator.addMethod(
    "phone",
    function (value) {
      return (
        value.trim().length === 0 ||
        /^\+?(?:[0-9] ?){6,14}[0-9]$/.test(value.trim())
      );
    },
    "Invalid phone number",
  );

  $("form").validate({
    rules: {
      "member[first_name]": "required",
      "member[last_name]": "required",
      "member[birth_date]": "required",
      "member[address]": "required",
      "member[house_number]": {
        required: true,
        digits: true,
      },
      "member[postal_code]": "required",
      "member[city]": "required",
      "member[phone_number]": {
        required: true,
        phone: true,
      },
      "member[emergency_phone_number]": {
        required: {
          depends: function () {
            // get max birth date to be 18 years old, ignoring time
            const maxDate = new Date();
            maxDate.setUTCHours(0, 0, 0, 0);
            maxDate.setFullYear(maxDate.getFullYear() - 18);

            const birthDate = new Date($("#member_birth_date").val());

            // field is valid if member is 18 years or if it's not empty
            return birthDate < maxDate;
          },
        },
        phone: true,
      },
      "member[email]": {
        required: true,
        email: true,
      },
      "member[student_id]": "required",
      bank: {
        required: {
          depends: function () {
            return $("select#method").val() === "IDEAL";
          },
        },
      },
    },
    errorClass: "is-invalid",
    errorElement: "div",
    errorPlacement: function (error, element) {
      error.addClass("invalid-feedback").appendTo(element.closest(".field"));
    },
    messages: {
      "member[first_name]": I18n.t("form.required_field"),
      "member[last_name]": I18n.t("form.required_field"),
      "member[birth_date]": I18n.t("form.required_field"),
      "member[address]": I18n.t("form.required_field"),
      "member[house_number]": {
        required: I18n.t("form.required_field"),
        digits: I18n.t("form.digits_field"),
      },
      "member[postal_code]": I18n.t("form.required_field"),
      "member[city]": I18n.t("form.required_field"),
      "member[phone_number]": {
        required: I18n.t("form.required_field"),
        phone: I18n.t("form.invalid_phone_number"),
      },
      "member[emergency_phone_number]": {
        required: I18n.t("form.required_field"),
        phone: I18n.t("form.invalid_phone_number"),
      },
      "member[email]": {
        required: I18n.t("form.required_field"),
        email: I18n.t("form.invalid_email"),
      },
      "member[student_id]": {
        required: I18n.t("form.required_field"),
      },
      bank: {
        required: I18n.t("form.required_field"),
      },
    },
  });
}

function setup_form_payment_method_watcher() {
  $("select#method").on("change", function () {
    $("select#bank").prop("disabled", $(this).val() === "Cash/PIN");
  });
}

function setup_form_studies_watcher() {
  let disabledStudyOptions = [];
  const studyBlockers = {
    1: 3,
    3: 1,
  };

  $(".studies select").on("change", function () {
    const selected = $(this).find("option:selected");

    if (selected.data("masters")) {
      $(".activities").hide();
    } else {
      $(".activities").show();
    }

    if (!$(this).closest(".form-group").is(":first-of-type")) {
      return;
    }

    if (disabledStudyOptions.length > 0) {
      $.each(disabledStudyOptions, function (_, v) {
        v.prop("disabled", false);
      });
      disabledStudyOptions = [];
    }

    disabledStudyOptions.push(
      $(this)
        .closest(".studies")
        .children()
        .last()
        .find(`option[value=${selected.val()}]`),
    );

    const blockedId = studyBlockers[selected.val()];
    if (typeof blockedId !== "undefined") {
      disabledStudyOptions.push(
        $(this)
          .closest(".studies")
          .children()
          .last()
          .find(`option[value=${blockedId}]`),
      );
    }

    $.each(disabledStudyOptions, function (_, v) {
      v.prop("disabled", true);
    });
  });
}
