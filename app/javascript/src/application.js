import $ from "jquery"

$(document).on("ready page:load turbolinks:load", function () {
  $(".alert button.close").on("click", function () {
    $(this).closest(".alert").remove();
  });
});
