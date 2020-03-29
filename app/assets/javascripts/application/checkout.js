$(document).on( 'ready page:load turbolinks:load', function(){

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
    }).done(function(){
      toastr.success('Kaart geactiveerd');
      $( row ).remove();
    }).fail(function(){
      toastr.error('Kaart is niet geactiveerd');
      $( button ).removeAttr( 'disabled' );
    });
  });

  // remove card
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
    }).done(function(){
      toastr.warning('Kaart verwijderd');
      $( row ).remove();
    }).fail(function(){
      toastr.erro('Kaart is niet verwijderd');
      $( button ).removeAttr( 'disabled' );
    });
  });

  // search members using dropdown
  var credit = $( '#credit' );
  var cardHolder = credit.find( 'input#card_holder' );
  var amountInput = credit.find( '.form-group input#amount' );
  var paymentMethodInput = credit.find('.form-group select#method');

  cardHolder.search().on( 'selected', function(event, id, name){

    $( this ).attr( 'disabled', 'disabled' ).val( name );
    credit.find( '.form-group#search_card' ).attr( 'data-id', id);

    credit.find( '.card-body.amount' ).css( 'display', 'block' );
    amountInput.focus();
  });

  // catch [ESC] to cancel
  amountInput.on( 'keyup', function( event, code ){
    if( event.keyCode === 27 || code === 27 ){
      credit.find( '.form-group#search_card input' ).removeAttr( 'disabled' ).val('');
      credit.find( '.form-group:not(#search_card)' ).css( 'display', 'none' );
      credit.find( '.form-group#search_card' ).removeAttr( 'data-id' ).removeClass( 'col-md-4' ).addClass( 'col-md-12' );
      cardHolder.focus();
      $( this ).val('');
    }
  });

  // after member is selected, set an amount
  credit.find( 'form' ).on( 'submit', function( event ){
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    event.preventDefault();
    if( amountInput.prop( 'disabled'))
      return;

    if( !amountInput.val()) {
      toastr.error('De opwaardering kan niet nul zijn');
      return;
    }

    var price = amountInput.val();

    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));

    amountInput.prop( 'disabled' , true );

    $.ajax({
      url: '/apps/transactions',
      type: 'PATCH',
      data: {
        member_id: credit.find( '.form-group#search_card' ).attr( 'data-id' ),
        amount: price,
        payment_method: paymentMethodInput.val(),
        authenticity_token: token
      }
    }).done(function( data ){
      amountInput.prop( 'disabled' , false);
      toastr.success('Checkout opgewaardeerd');

      //toevoegen aan de lijst
      $( '#transactions' ).trigger( 'transaction_added', data ); //TODO

      //formulier terugveranderen
      credit.find( '.form-group#search_card input' ).removeAttr( 'disabled' ).val('');
      credit.find( '.card-body.amount' ).css( 'display', 'none' );
      credit.find( '.form-group#search_card' ).removeAttr( 'data-id' );
      cardHolder.focus();
      amountInput.val('');

      //Reset select (payment_method)
      paymentMethodInput.val('');

    }).fail(function( data ){
      amountInput.prop( 'disabled' , false );

      if( data.status === 404 )
        toastr.error('Er is geen kaart gevonden');

      if( data.status === 413 )
        toastr.error(data.responseText, data.status);

      if( data.status === 400 )
        toastr.error('Het bedrag moet numeriek zijn');
    });
  });

});
