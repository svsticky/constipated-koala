// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
//= require bootstrap-file-input

$(document).on( 'ready page:load', function(){

  $( '#settings input[id^=\'options\']' ).on( 'keypress', function( e ){
    if(e.which != 13)
      return
    e.preventDefault();

    $(this).blur();

    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));
    var obj = this;

    $.ajax({
      url: '/settings',
      type: 'POST',
      data: {
        authenticity_token: token,
        setting: obj.name,
        value: obj.value
      }
    }).fail(function(){
      alert( 'Instelling is niet opgeslagen', 'error' );
    });
  });

  // remove advert
  $( 'div#advertisements tr .btn-group button.destroy' ).bind( 'click', function() {
    var button = $( this );
    var row = $( this ).closest( 'tr' );
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    $.ajax({
      url: '/settings/advertisement',
      type: 'DELETE',
      data: {
        id: $( row ).attr( 'data-id' ),
        authenticity_token: token
      }
    }).done(function( data, status ){
      alert( 'Advertentie verwijderd', 'success' );
      $( row ).remove();
    }).fail(function(){
      alert( 'Advertentie is niet verwijderd', 'error' );
    });
  });
});
