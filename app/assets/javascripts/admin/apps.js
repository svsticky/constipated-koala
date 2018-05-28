//
//= require bootstrap-file-input

$(document).on( 'ready page:load turbolinks:load', function(){

  bind_flip();

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
    }).done(function(){
      alert( 'Kaart geactiveerd', 'success' );
      $( row ).remove();
    }).fail(function(){
      alert( 'Kaart is niet geactiveerd', 'error' );
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
    }).done(function(){
      alert( 'Kaart verwijderd', 'warning' );
      $( row ).remove();
    }).fail(function(){
      alert( 'Kaart is niet geactiveerd', 'error' );
      $( button ).removeAttr( 'disabled' );
    });
  });

  var credit = $( '#credit' );
  // search members using dropdown
  var cardHolder = credit.find( 'input#card_holder' );
  var amountInput = credit.find( '.form-group input#amount' );
  var paymentMethodInput = credit.find('select#payment_method');
  cardHolder.search().on( 'selected', function(event, id, name){

    $( this ).attr( 'disabled', 'disabled' ).val( name );
    credit.find( '.form-group#search_card' ).attr( 'data-id', id).removeClass( 'col-md-12' ).addClass( 'col-md-4' );

    credit.find( '.form-group' ).css( 'display', 'block' );
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
  credit.find( 'form.form-inline' ).on( 'submit', function( event ){
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    event.preventDefault();
    if( amountInput.prop( 'disabled'))
      return;

    if( !amountInput.val()) {
      alert ( 'De opwaardering kan niet nul zijn', 'error');
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
      alert( 'Checkout opgewaardeerd', 'success' );

      //toevoegen aan de lijst
      $( '#transactions' ).trigger( 'transaction_added', data ); //TODO

      //formulier terugveranderen
      amountInput.trigger( 'keyup', [27]);

      //Reset select (payment_method)
      paymentMethodInput.val('');

    }).fail(function( data ){
      amountInput.prop( 'disabled' , false );

      if( data.status === 404 )
        alert( 'Er is geen kaart gevonden', 'error' );

      if( data.status === 413 )
        alert( data.responseText, 'error' );

      if( data.status === 400 )
        alert( 'Het bedrag moet numeriek zijn', 'error' );
    });
  });

  // [DELETE] checkout_product
  $('#products button.destroy').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    if( !confirm($(row).find('a').html() + ' verwijderen?') )
      return;

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

    params.date = $(this).val();
    location.search = $.param(params);
  });

  $('form').on('submit', function(){
    $( this ).find('button[type="submit"].wait').addClass('disabled');
  });

});

function bind_flip(){
  //Reset all event handlers
  $('#products button').off('click');

  $('#products').find('button.activate').on('click', product.activate);

  $('#products').find('button.deactivate').on('click', product.deactivate);;
}

var product = {
  deactivate : function(){
    var row = $(this).closest('tr');

    $.ajax({
      url: '/apps/products/' + row.attr( 'data-id' ) + '/flip',
      type: 'PATCH',
      data: {
        checkout_product: {
          active: false
        }

      }
    }).done(function(){
      alert($(row).find('a').html() + ' is gedeactiveerd', 'success');

      $(row)
        .addClass('inactive')
        .find( 'button.deactivate' )
        .empty()
        .removeClass( 'deactivate btn-warning' )
        .addClass( 'activate btn-primary' )
        .append( '<i class="fa fa-fw fa-check"></i> Activeer' );

      //Reset all event handlers
      bind_flip();

    }).fail(function(){
      alert( 'Not working', 'error' );
    });
  },

  activate : function(){
    var row = $(this).closest('tr');

    $.ajax({
      url: '/apps/products/' + row.attr('data-id') + '/flip',
      type: 'PATCH',
      data: {
        checkout_product: {
          active: true
        }
      }
    }).done(function(){
      alert($(row).find('a').html() + ' is geactiveerd', 'success');

      $(row)
        .removeClass( 'inactive' )
        .find( 'button.activate' )
        .empty()
        .removeClass( 'activate btn-primary inactive' )
        .addClass( 'deactivate btn-warning' )
        .append( '<i class="fa fa-fw fa-times"></i> Deactiveer' );

        bind_flip();

    }).fail(function(){
      alert( 'Not working', 'error' );
    });
  }
};
