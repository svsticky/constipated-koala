// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function bind_activities(){
  //reset all binds
  $('#participants button').off('click');
  $('#participants input.price').off('focusout');

  // Activiteiten betalen met een async call
  // [PATCH] participants
  $('#participants').find('button.paid').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        paid: true
      }
    }).done(function(){
      alert($(row).find('a').html() + ' is betaald', 'success');

      $(row).find( 'button.paid' ).empty().removeClass( 'paid btn-warning' ).addClass( 'unpaid btn-primary' ).append( '<i class="fa fa-fw fa-check"></i>' );
      $(row).removeClass( 'red' );

      bind_activities();
    }).fail(function(){
      alert( '', 'error' );
    });
  });

  // Activiteiten op niet betaald zetten
  // [PATCH] participants
  $('#participants').find('button.unpaid').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        paid: false
      }
    }).done(function(){
      alert($(row).find( 'a' ).html() + ' is niet betaald', 'warning' );

      $(row).find( 'button.unpaid' ).empty().addClass( 'paid btn-warning' ).removeClass( 'unpaid btn-primary' ).append( '<i class="fa fa-fw fa-times"></i>' );
      $(row).addClass( 'red' );

      bind_activities();
    }).fail(function(){
      alert( '', 'error' );
    });
  });

  // Deelname aan activiteiten verwijderen
  // [DELETE] participants
  $('#participants button.destroy').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/participants',
      type: 'DELETE',
      data: {
        id: id,
        authenticity_token: token
      }
    }).done(function(){
      alert($(row).find('a').html() + ' is verwijderd', 'warning');
      $(row).remove();

    }).fail(function(){
      alert( '', 'error' );
    });
  });
}

$(document).on('ready page:load', function(){
  bind_activities();

  $( '#credit' ).find( '.btn' ).on( 'click', function( event ){
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));

    if( !$( '#credit input#amount' ).val() )
      return

    var price = $( '#credit input#amount' ).val();
    
    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));

    $.ajax({
      url: '/checkout/transaction',
      type: 'PATCH',
      data: {
        member_id: $( '#credit' ).attr( 'data-member-id' ),
        amount: price,
        authenticity_token: token
      }
    }).done(function( data ){
      alert( 'checkout opgewaardeerd', 'success' );

      //toevoegen aan de lijst
      $( '#transactions' ).trigger( 'transaction_added' ); //TODO

      //formulier terugveranderen
      $( '#credit' ).find( 'input#amount' ).val('');

    }).fail(function( data ){
      if( data.status == 404 )
        alert( 'er is geen kaart gevonden', 'error' );

      if( data.status == 413 )
        alert( 'er is onvoldoende saldo', 'error' );

      if( data.status == 400 )
        alert( 'het bedrag moet numeriek zijn', 'error' );
    });
  });

  $('table#transactions select.uuid').bind( 'change', function(){
    var params = {}
    if( $( this ).val() != '' )
      params['uuid'] = $(this).val();
    location.search = $.param(params);
  });

  $('label a.close').bind( 'click', function() {
    var row = $('.copyable:last').clone().insertAfter($('.copyable:last'));

    //member[educations_attributes][39][name_id]
    var name = $(row).find('select').attr('name');
    var id = name.match(/\[(-?\d*\d+)\]/)[1];

    if(+id < 0)
      id = +id - 1;
    else
      id = -1;

    //replace all inputs and select name and id?
    $(row).find('input').each(function() {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)\]/, '[' + id + ']'));
    });

    $(row).find('select').each(function() {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)\]/, '[' + id + ']'));
    });
  });

  function destroy(){
    $('.form-group a.btn.destroy').bind( "click", function(){
      var row = $( this ).closest('.form-group');

      var destroy = $( row ).find('input.destroy');
      console.log(destroy.val());

      if(destroy.val() == 'true'){
        $( row ).find('input').removeAttr('disabled');
        $( row ).find('select').removeAttr('disabled').removeAttr('style').css('width', '100%');

        $( destroy ).val("false")
        $( this ).html("<span class='fa fa-trash-o'></span>");
      }else{
        if(!$( row ).find('input.id').val())
          $( row ).find('input[type="hidden"]').attr('disabled', 'disabled');
        $( row ).find('input.form-control').attr('disabled', 'disabled');
        $( row ).find('select').attr('disabled', 'disabled').css('background-color', 'rgb(238, 238, 238)').css('color', 'rgb(118, 118, 118)').css('border-color', 'rgb(203, 213, 221)');

        $( destroy ).val("true")
        $( this ).html("<span class='fa fa-undo'></span>");
      }

    });
  }

  destroy();
});
