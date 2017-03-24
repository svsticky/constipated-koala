// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function bind_group_members(){
  //reset all binds
  $('#members button.destroy').off('click');
  $('#members select.position').off('change');

  // Deelname aan groep verwijderen
  // [DELETE] groups
  $('#members button.destroy').on('click', function( event ){
    event.preventDefault();

    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    if( !confirm($(row).find('a').html() + ' verwijderen?') )
      return;

    $.ajax({
      url: '/groups/' + $('table#members').attr('data-id') + '/members/' + row.attr( 'data-id' ),
      type: 'DELETE',
      data: {
        authenticity_token: token
      }
    }).done(function(){
      alert($(row).find('a').html() + ' verwijderd', 'warning');
      $(row).remove();

      $('#mail').trigger('recipient_removed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $( 'input#search' ).select();
    }).fail(function(){
      alert( '', 'error' );
    });
  });

  // Functie aanpassen
  // [PATCH] groups member
  $('#members').find('select.position').on('change', function(){
    var row = $(this).closest('tr');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var position = $(this).val();

    $.ajax({
      url: '/groups/' + $('table#members').attr('data-id') + '/members/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        position: position
      }
    }).done(function( data ){
      alert( 'functie is gewijzigd' );
    }).fail(function( data ){
      alert( 'geen verbinding of geen id', 'error' );
    });
  });
}

$(document).on( 'ready page:load', function(){
  bind_group_members();

  $('#members').find('input#member').search().on('selected', function(event, id, name){
    event.preventDefault();

    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));

    $.ajax({
      url: '/groups/' + $('table#members').attr('data-id') + '/members',
      type: 'POST',
      data: {
        authenticity_token: token,
        member: id,
        year: $('table#members').attr('data-year')
      }
    }).done(function( data ){
      var template = $('template#group_member').html();
      var member = template.format(data.id, data.member_id, name);
      var added = $(member).insertBefore('table#members tr:last');

      bind_activities();

      $( '#members input.position:last' ).focus();
    }).fail(function(){
      alert( 'Deze persoon is al toegevoegd', 'warning' );
    });
  });
});
