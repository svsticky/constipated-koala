$(document).on( 'ready page:load turbolinks:load', function(){

  // init mail helper
  $('#mail-editor #editor').mail();


  // Add confirmation if participant_limit is changed
  // $('#activity_participant_limit').on('change', function() {
  //   // TODO overloop deelnemers, alle behalve [limit] naar reservist?
  //   $('.btn.btn-success.wait[type="submit"]').attr('data-confirm', "Deelnemerslimiet aanpassen?");
  // });
});
