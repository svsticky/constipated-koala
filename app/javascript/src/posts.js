// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
import "jquery";

$(document).on("ready page:load turbolinks:load", function () {
  $(".form-group.post-content").editor({
    toolbar: [
      [{ header: [1, 2, 3, 4, false] }],
      ["bold", "italic", "underline", "strike"],
      [{ list: "ordered" }, { list: "bullet" }],
      ["link", { color: [] }],
      ["clean"],
    ],
  });
});
