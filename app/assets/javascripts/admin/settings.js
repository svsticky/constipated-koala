// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
//= require bootstrap-file-input

$(document).on( 'ready page:load', function(){
  $( 'ul#settings' ).find( '.col-md-6 input' ).bind( 'change', function(){
      var setting = $( this );
      var current = $( setting ).val();
      var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

      $.ajax({
        url: '/settings/update',
        type: 'PATCH',
        data: {
          setting: $( setting ).attr( 'name' ),
          value: $( setting ).val(),
          authenticity_token: token
        }
      }).done(function(){
        alert( 'Instelling gewijzigd', 'success' );
      }).fail(function(){
        alert( 'Instelling is niet gewijzigd', 'error' );
        $( setting ).val( current )
      });
  })

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
