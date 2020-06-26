$(document).on("ready page:load turbolinks:load", function () {
  setup_intl_tel_input();

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
