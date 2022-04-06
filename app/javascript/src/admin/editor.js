import $ from "jquery";

// Here you can define all the Quill editors

$(document).on("ready page:load turbolinks:load", function () {
  $("form.signature").editor();
  $("form.post-content").editor();
});
