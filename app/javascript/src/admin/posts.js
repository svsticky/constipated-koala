import "flatpickr"

$(document).on("ready page:load turbolinks:load", function () {
  let datePicker = $(".publish-datetime")[0];
  if (datePicker) {
    datePicker.flatpickr({
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      time_24hr: true,
    });
  }
});
