$(document).on('ready page:load turbolinks:load', function(){

  //Initialise clipboard-rails for the whatsapp messages
  var clip = new Clipboard('#paymentmails .btn-clipboard', {
    text: function(trigger) {
      return getWhatsappText(trigger.getAttribute('data-texturl'));
    }
  });

  //Update search
  $('input#search').on('keyup', function(){
    var query = new RegExp( $( this ).val(), 'i');

    $( '.filtered-search table' ).each( function( index, table ){
      $( table ).find( 'tbody tr' ).each( function( index, row ){

        if( query.test( $( row ).attr( 'data-name' )))
          $( row ).removeClass('d-none');
        else
          $( row ).addClass('d-none');
      });

      if( $( table ).find( 'tbody tr' ).not( '.d-none' ).length > 0 )
        $( table ).removeClass('d-none');
      else
        $( table ).addClass('d-none');
    });
  });

  //Update shown transactions with a start date
  $( '.input-group#transaction_dates #update_transactions button' ).bind( 'click', function() {
    getCheckoutTransactions($(this));
  });

  //Initialise clipboard-rails for the checkout transactions
  (function(){
      new Clipboard('#copy_transactions .btn-clipboard');
  })();
});

//Requests whatsapp message from server for member
function getWhatsappText (url) {
  return $.ajax({
    url: url,
    success: function() {
      toastr.success('Bericht gekopieerd naar klembord');
    },
    error: function() {
      toastr.error('Bericht kon niet worden opgehaald');
    },
    async: false
  }).responseText;
}

//Requests all checkout transactions for a given date
function getCheckoutTransactions (button) {
  var start_date = $('#pin-total-date').val();

  $.ajax({
    url: '/payments/transactions',
    type: 'GET',
    data: {
      start_date: start_date
    }
  }).done(function( data, status ){
    //Find and clear table
    var table = $("#transactions").find('tbody');
    var total = 0.0;
    $(table).find("tr").remove();

    // Bind json data to copy button
    $("#copy_transactions button").attr("data-clipboard-text", JSON.stringify(data));

    //Fill table if not empty
    if (data.length == 0){
      table.append('<tr style="height: 36px; line-height: 36px;"><td><em>Geen transacties</em></td><td></td><td></td></tr>')
      toastr.warning('Geen transacties gevonden');
    }
    else {
      $.each(data, function(key, t) {
        let value = parseFloat(t.price);
        total += value;
        t.price = '€' + value.toFixed(2);
        if (t.price.indexOf('-') > 0) t.price = "-€" + t.price.substring(2);
        table.append('<tr style="height: 36px; line-height: 36px;"><td><a href="/members/' + t.member_id + '">' + t.name + '</a></td><td>' + t.price + '</td><td>' + t.date + '</td></tr>')
      });
      toastr.success('Transacties gevonden');
    }
    $("#pin-total-result").text("€" + total.toFixed(2));
  }).fail(function(){
    toastr.error('Kon niet updaten');
  });
}
