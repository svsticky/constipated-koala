// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on( 'ready page:load turbolinks:load', function(){
  $('form.post-content').editor();
});
