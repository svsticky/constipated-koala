//
//= require bootstrap-file-input

$(document).on( 'ready page:load', function(){

  $('form .input-group-btn .file-input-wrapper input[type="file"]').on('change', function(){
    if( this.files && this.files[0] ){
      $('form .input-group input#output').val(this.files[0].name);
    }
  });

  // activate card
  $( 'div#cards ul.list-group .btn-group button:nth-child(1)' ).bind( 'click', function() {
    var button = $( this );
    var row = $( this ).closest( '.list-group-item' );
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    $( button ).attr( 'disabled', 'disabled' );

    $.ajax({
      url: '/apps/cards',
      type: 'PATCH',
      data: {
        uuid: $( row ).attr( 'data-uuid' ),
        authenticity_token: token
      }
    }).done(function( data, status ){
      alert( 'kaart geactiveerd', 'success' );
      $( row ).remove();
    }).fail(function(){
      alert( 'kaart is niet geactiveerd', 'error' );
      $( button ).removeAttr( 'disabled' );
    });
  });

  $( 'div#cards ul.list-group .btn-group button:nth-child(2)' ).bind( 'click', function() {
    var button = $( this );
    var row = $( this ).closest( '.list-group-item' );
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    $( button ).attr( 'disabled', 'disabled' );

    $.ajax({
      url: '/apps/cards',
      type: 'PATCH',
      data: {
        uuid: $( row ).attr( 'data-uuid' ),
        authenticity_token: token,
        _destroy: true
      }
    }).done(function( data, status ){
      alert( 'kaart verwijderd', 'warning' );
      $( row ).remove();
    }).fail(function(){
      alert( 'kaart is niet geactiveerd', 'error' );
      $( button ).removeAttr( 'disabled' );
    });
  });

  // search members using dropdown
  $( '#credit' ).find( 'input#card_holder' ).search().on( 'selected', function(event, id, name){

    $( this ).attr( 'disabled', 'disabled' ).val( name );
    $( '#credit .form-group#card' ).attr( 'data-id', id).removeClass( 'col-md-12' ).addClass( 'col-md-4' );

    $( '#credit .form-group' ).css( 'display', 'block' );
    $( '#credit .form-group input#amount' ).focus();
  });

  // catch [ESC] to cancel
  $( '#credit' ).find( 'input#amount' ).on( 'keyup', function( event, code ){
    if( event.keyCode == 27 || code == 27 ){
      $( '#credit .form-group#card input' ).removeAttr( 'disabled' ).val('');
      $( '#credit .form-group:not(#card)' ).css( 'display', 'none' );
      $( '#credit .form-group#card' ).removeAttr( 'data-id' ).removeClass( 'col-md-4' ).addClass( 'col-md-12' );
      $( '#credit input#card_holder' ).focus();
      $( '#credit input#amount' ).val('');
    }
  });

  // after member is selected, set an amount
  $( '#credit' ).find( 'form.form-inline' ).on( 'submit', function( event ){
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    event.preventDefault();
    if( $( '#credit .form-group input#amount' ).prop( 'disabled'))
      return

    if( !$( '#credit .form-group input#amount' ).val() )
      return

    var price = $( '#credit .form-group input#amount' ).val();

    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));

    $( '#credit .form-group input#amount' ).prop( 'disabled' , true );

    $.ajax({
      url: '/apps/transactions',
      type: 'PATCH',
      data: {
        member_id: $( '#credit .form-group#card' ).attr( 'data-id' ),
        amount: price,
        authenticity_token: token
      }
    }).done(function( data ){
      $( '#credit .form-group input#amount' ).prop( 'disabled' , false );
      alert( 'checkout opgewaardeerd', 'success' );

      //toevoegen aan de lijst
      $( '#transactions' ).trigger( 'transaction_added', data ); //TODO

      //formulier terugveranderen
      $( '#credit' ).find( 'input#amount' ).trigger( 'keyup', [27]);

    }).fail(function( data ){
      $( '#credit .form-group input#amount' ).prop( 'disabled' , false );

      if( data.status == 404 )
        alert( 'er is geen kaart gevonden', 'error' );

      if( data.status == 413 )
        alert( 'er is onvoldoende saldo', 'error' );

      if( data.status == 400 )
        alert( 'het bedrag moet numeriek zijn', 'error' );
    });
  });

  // after member is selected, set an amount
  $( '#credit.input-group > span > button' ).on( 'click', function( event ){
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    if( !$( '#credit input#amount'  ).val() )
      return

    if( $( '#credit.input-group > #amount' ).prop( 'disabled' ))
      return

    var price = $( '#credit input#amount' ).val();

    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));

    $( '#credit.input-group > #amount' ).prop( 'disabled' , true );

    $.ajax({
      url: '/apps/transactions',
      type: 'PATCH',
      data: {
        member_id: $( '#credit.input-group' ).attr( 'data-member-id' ),
        amount: price,
        authenticity_token: token
      }
    }).done(function( data ){
      $( '#credit.input-group > #amount' ).prop( 'disabled' , false );
      alert( 'checkout opgewaardeerd', 'success' );

      //toevoegen aan de lijst
      $( '#transactions' ).trigger( 'transaction_added', data ); //TODO

      //remove from input
      $( '#credit.input-group > #amount' ).val('');

    }).fail(function( data ){
      $( '#credit.input-group > #amount' ).prop( 'disabled' , false );

      if( data.status == 404 )
        alert( 'er is geen kaart gevonden', 'error' );

      if( data.status == 413 )
        alert( 'er is onvoldoende saldo', 'error' );

      if( data.status == 400 )
        alert( 'het bedrag moet numeriek zijn', 'error' );
    });
  });


  // [DELETE] checkout_product
  $('#products button.destroy').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    if( !confirm($(row).find('a').html() + ' verwijderen?') )
      return

    $.ajax({
      url: '/apps/products',
      type: 'DELETE',
      data: {
        id: id,
        authenticity_token: token
      }
    }).done(function(){
      alert($(row).find('a').html() + ' verwijderd', 'info');
      $(row).remove();
    }).fail(function(){
      alert( '', 'error' );
    });
  });


  $('.date-input input').on('change', function(){
    var params = {};

    params['date'] = $(this).val();
    location.search = $.param(params);
  });

  $('form').on('submit', function(){
    $( this ).find('button[type="submit"].wait').addClass('disabled');
  });
});
