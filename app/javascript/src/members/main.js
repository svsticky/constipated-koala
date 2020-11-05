$(document).on("ready page:load turbolinks:load", function () {
  setup_intl_tel_input();

  // Needed to update the participant and reservist tables in the activity view
  String.prototype.format = function () {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function (match, number) {
      return typeof args[number] != "undefined" ? args[number] : match;
    });
  };

  // Callback handler for menu
  $(".toggle-min").click(function (event) {
    event.preventDefault();

    $("#app").children("div").toggleClass("nav-min");
  });

  $("#year").on("change", function () {
    var params = {};

    params.year = $(this).val();
    location.search = $.param(params);
  });
});
