$(document).on("ready page:load turbolinks:load", function () {
  $(".publish-datetime")[0].flatpickr({
    enableTime: true,
    dateFormat: "Y-m-d H:i",
  });
});
