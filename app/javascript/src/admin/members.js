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
      document.activeElement &&
      (["input", "textarea"].includes(
        document.activeElement.tagName.toLowerCase(),
      ) ||
        document.activeElement.isContentEditable)
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

  // after member is selected, set an amount
  var creditInputGroup = $("#credit.input-group");
  var inputAmount = creditInputGroup.find("input#amount");
  var paymentMethodInput = creditInputGroup.find("select#payment_method");
  creditInputGroup.find("#upgrade-btn").on("click", function () {
    var token = encodeURIComponent(
      $(this).closest(".page").attr("data-authenticity-token"),
    );

    if (!inputAmount.val()) {
      toastr.error(I18n.t("admin.members.top_up_error"));
      return;
    }

    if (inputAmount.prop("disabled")) return;

    var price = $(inputAmount).val();

    // Make it a bit more pretty
    if (!isNaN(price)) $(this).val(parseFloat(price).toFixed(2));

    inputAmount.prop("disabled", true);

    $.ajax({
      url: "/apps/transactions",
      type: "PATCH",
      data: {
        member_id: creditInputGroup.attr("data-member-id"),
        amount: price,
        payment_method: paymentMethodInput.val(),
        authenticity_token: token,
      },
    })
      .done(function (data) {
        inputAmount.prop("disabled", false);
        toastr.success(I18n.t("admin.members.top_up"));

        //toevoegen aan de lijst
        $("#transactions").trigger("transaction_added", data); //TODO

        //remove from input and select
        paymentMethodInput.val("");
        inputAmount.val("");
      })
      .fail(function (data) {
        inputAmount.prop("disabled", false);

        if (!data.responseJSON) {
          toastr.error(data.statusText, data.status);
          return;
        }

        let errors = data.responseJSON.errors;
        let text = "";
        for (let attribute in errors) {
          for (let error of errors[attribute]) text += error + ", ";

          // remove last colon and space
          text = text.slice(0, -2);
          text += "<br/>";
        }
        // remove last line break
        text = text.slice(0, -5);

        toastr.error(text);
      });
  });

  destroy(null);

  $("#memberscards button").on("click", button_action);

  function button_action() {
    let row = $(this).closest("tr");
    let status = $(row).children(".cardstatus");
    let uuid = row.attr("data-uuid");
    let memberid = row.attr("data-member-id");
    let token = encodeURIComponent(
      $(this).closest(".page").attr("data-authenticity-token"),
    );

    let tobeactivated = row.attr("data-active") == 0;
    let disabled = row.attr("data-disabled") == 1;

    let entry =
      "admin.cards." +
      (tobeactivated ? "" : disabled ? "re" : "de") +
      "activate_confirm";
    if (!confirm(I18n.t(entry, { uuid: uuid }))) return;

    let url = tobeactivated
      ? "/apps/cards"
      : "/members/" + memberid + "/set_card_disabled/" + uuid;
    let successmsg = tobeactivated
      ? I18n.t("checkout.card.activated")
      : disabled
        ? I18n.t("admin.cards.activate_success", { uuid: uuid })
        : I18n.t("admin.cards.deactivate_success", { uuid: uuid });

    $.ajax({
      url: url,
      type: "PATCH",
      data: {
        authenticity_token: token,
        uuid: uuid, // only needed for 'to be activated',
        to: !disabled, // only needed for toggling 'disabled'
      },
    })
      .done(() => {
        // Remove current classes
        if (tobeactivated) {
          status.removeClass("text-info");
          $(this).removeClass("activate btn-primary");
          row.attr("data-active", 1);
        } else if (disabled) {
          status.removeClass("text-muted");
          $(this).removeClass("reactivate btn-warning");
        } else {
          $(this).removeClass("deacticate btn-danger");
        }
        // Add new classes & content
        if (disabled ^ tobeactivated) {
          status.empty().append(I18n.t("admin.cards.active"));
          $(this)
            .empty()
            .append(
              '<i class="fa fa-trash"></i>' + I18n.t("admin.cards.deactivate"),
            )
            .addClass("deactivate btn-danger");
          row.attr("data-disabled", 0);
        } else {
          status
            .empty()
            .append(I18n.t("admin.cards.deactivated"))
            .addClass("text-muted");
          $(this)
            .empty()
            .append(
              '<i class="fa fa-sync-alt"></i>' +
                I18n.t("admin.cards.reactivate"),
            )
            .addClass("reactivate btn-warning");
          row.attr("data-disabled", 1);
        }
        toastr.success(successmsg);
      })
      .fail((e) => {
        toastr.error(e.statusText, e.status);
      });
  }
});
