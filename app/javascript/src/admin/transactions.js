//
//= require bootstrap-file-input
import $ from "jquery";

$(document).on("ready page:load turbolinks:load", function () {
  $(document).on("click", ".allow-focus", function (e) {
    e.stopPropagation();
  });

  $('form .input-group-btn .file-input-wrapper input[type="file"]').on(
    "change",
    function () {
      if (this.files && this.files[0]) {
        $("form .input-group input#output").val(this.files[0].name);
      }
    },
  );

  $(".date-input input").on("change", function () {
    var params = {};

    params.date = $(this).val();
    location.search = $.param(params);
  });

  $("form").on("submit", function () {
    $(this).find('button[type="submit"].wait').addClass("disabled");
  });
});
