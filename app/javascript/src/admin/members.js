import $ from "jquery";
import I18n from "../translations.js";
import toastr from "toastr";

import { setup_intl_tel_input } from "../intl_tel_number";

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//=require intl_tel_number

$(document).on("ready page:load turbolinks:load", function () {
  setup_intl_tel_input();

  $(window).on("keydown", (evt) => {
    // <input>, <textarea>, or the mailer input field
    if (
      $("input").is(":focus") ||
      $("textarea").is(":focus") ||
      document.getElementById("editor")?.contains(document.activeElement)
    ) {
      // Cancel if any inputs are selected
      return;
    }

    // Edit member
    if (evt.key === "e") {
      document.getElementById("member-btn-edit")?.click();
    }

    // Cancel editing
    if (evt.key === "Escape" || (evt.key === "Delete" && evt.ctrlKey)) {
      document.getElementById("admin-member-edit-btn-cancel")?.click();
      return;
    }

    // Save editing
    if (evt.key === "Enter" && evt.ctrlKey) {
      document.getElementById("admin-member-edit-btn-save")?.click();
    }

    // Set status of first study to 'Afgestudeerd'
    if (evt.key === "a" && !evt.ctrlKey) {
      $($(".educ-status select")[0]).val("inactive").change();
    }

    // Set status of second study to 'Afgestudeerd'
    if (evt.key === "a" && evt.ctrlKey) {
      evt.preventDefault();

      $($(".educ-status select")[1]).val("inactive").change();
    }
  });

  $(".education label a.close").bind("click", function () {
    var row = $(".education .copyable:last")
      .clone()
      .insertAfter($(".education .copyable:last"));

    //member[educations_attributes][39][name_id]
    var name = $(row).find("select").attr("name");
    var id = name.match(/\[(-?\d*\d+)]/)[1];

    if (+id < 0) id = +id - 1;
    else id = -1;

    //replace all inputs and select name and id?
    $(row)
      .find("input")
      .each(function () {
        $(this)
          .val("")
          .attr(
            "name",
            $(this)
              .attr("name")
              .replace(/\[(-?\d*\d+)]/, "[" + id + "]"),
          );
      });

    $(row)
      .find("select")
      .each(function () {
        $(this)
          .val("")
          .attr(
            "name",
            $(this)
              .attr("name")
              .replace(/\[(-?\d*\d+)]/, "[" + id + "]"),
          );
      });

    destroy(row);
  });

  function destroy(el) {
    var selector = $(".education .form-group a.btn.destroy");

    if (typeof el !== "undefined" && el !== null)
      selector = $(el).find("a.btn.destroy");

    $(selector).bind("click", function () {
      var row = $(this).closest(".form-group");

      var destroy = $(row).find("input.destroy");

      if (destroy.val() == "true") {
        $(row).find("input").removeAttr("disabled");
        $(row)
          .find("select")
          .removeAttr("disabled")
          .removeAttr("style")
          .css("width", "100%");

        $(destroy).val("false");
        $(this).html("<span class='fa fa-trash'></span>");
        $(row).find("input.form-control").attr("disabled", "disabled");
      } else {
        if (!$(row).find("input.id").val())
          $(row).find('input[type="hidden"]').attr("disabled", "disabled");
        $(row).find("input.form-control").attr("disabled", "disabled");
        $(row)
          .find("select")
          .attr("disabled", "disabled")
          .css("background-color", "rgb(238, 238, 238)")
          .css("color", "rgb(118, 118, 118)")
          .css("border-color", "rgb(203, 213, 221)");

        $(destroy).val("true");
        $(this).html("<span class='fa fa-undo'></span>");
      }
    });
  }
});
