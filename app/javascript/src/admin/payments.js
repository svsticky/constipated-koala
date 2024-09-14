import $ from "jquery";
import I18n from "../translations.js";
import Clipboard from "clipboard";
import toastr from "toastr";

$(document).on("ready page:load turbolinks:load", function () {
  //Initialise clipboard-rails for the whatsapp messages
  var clip = new Clipboard("#paymentmails .btn-clipboard", {
    text: function (trigger) {
      return getWhatsappText(trigger.getAttribute("data-texturl"));
    },
  });

  $("#export-transactions").bind(
    "ajax:error",
    function (event, xhr, status, error) {
      toastr.error(I18n.t("admin.payment.not_found"));
    },
  );

  //Update search
  $("input#search").on("keyup", function () {
    var query = new RegExp($(this).val(), "i");

    $(".filtered-search table").each(function (index, table) {
      $(table)
        .find("tbody tr")
        .each(function (index, row) {
          if (query.test($(row).attr("data-name")))
            $(row).removeClass("d-none");
          else $(row).addClass("d-none");
        });

      if ($(table).find("tbody tr").not(".d-none").length > 0)
        $(table).removeClass("d-none");
      else $(table).addClass("d-none");
    });
  });

  //Initialise clipboard-rails for the checkout transactions
  (function () {
    new Clipboard("#copy_transactions .btn-clipboard");
  })();
});

//Requests whatsapp message from server for member
function getWhatsappText(url) {
  return $.ajax({
    url: url,
    success: function () {
      toastr.success(I18n.t("admin.payment.whatsapp.copy"));
    },
    error: function () {
      toastr.error(I18n.t("admin.payment.whatsapp.copy_error"));
    },
    async: false,
  }).responseText;
}
