/*
 * Bind all handlers to the buttons
 */
function bind_activities(){
  //Reset all event handlers
  $('#participants button').off('click');
  $('#participants input.price').off('change');

  // Admin marks participant as having paid
  // [PATCH] participants
  $('#participants').find('button.paid').on('click', participant.updatePaid);
  $('#participants').find('button.unpaid').on('click', participant.updateUnpaid);
  $('#participants').find('input.price').on('change', participant.updatePrice);
  $('#participants button.toparticipant').on('click', participant.upgrade);

  // Admin deletes participant from activity
  // [DELETE] participants
  $('#participants button.destroy').on('click', participant.delete);
}

/*
 * Participant namespace containing all participant related functions
 */
var participant = {

  //Admin adds a new participant to the activity
  add : function(data){
    var template = $('template#attendee-table-row').html().format(
        data.id,
        data.member.id,
        data.member.name,
        data.member.email
    );

    var added = $(template).insertBefore('#participants-table tr:last');

    if(data.activity.price > 0)
      $(added).addClass('in-debt');
    else
      $(added).find( 'button.paid' ).addClass( 'd-none' );

    $('#attendeecount').html(data.activity.fullness);
    bind_activities();

    // trigger #mail client to add recipient
    $('#mail').trigger('recipient_added', [ data.id, data.member.name, data.member.email, data.activity.price ]);
    $( '#participants .form-group input#participants' ).focus();
  },

  //Admin deletes participant from activity
  delete : function (){
    var row = $(this).closest('tr');
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($('meta[name=csrf-token]').attr('content'));

    if(!confirm('Deelname van ' + $(row).find('a').html() + ' verwijderen?'))
      return;

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'DELETE',
      data: {
        authenticity_token: token
      }
    }).done(function(data){
      toastr.warning($(row).find('a').html() + ' verwijderd');
      $(row).remove();

      //Move reservist to attendees if applicable
      if (data.magic_reservists && data.magic_reservists.length > 0) {
        data.magic_reservists.forEach(
          function(item, index, array) {
            $("#reservists-table tbody tr:nth-child(2)").remove();
            participant.add(item, item.name);
          });
      } else {
          // Not already done in participant.add above
        $('#attendeecount').html(data.fullness);
      }

      $('#mail').trigger('recipient_removed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $('input#search').select();
    }).fail(function(error){
      toastr.error(error.statusText, error.status);
    });
  },

  // Upgrade from reservists to participants by admin
  upgrade : function (){
    var token = encodeURIComponent($('meta[name=csrf-token]').attr('content'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        reservist: false
      }
    }).done(function(data){
      toastr.success(data.member.name + ' is op de deelnemerslijst geplaatst');
      participant.add(data);

      $(row).remove();
      bind_activities();

      $('#reservistcount').html(data.activity.reservist_count);
    }).fail(function(error){
      toastr.error(error.statusText, error.status);
    });
  },

  //Admin marks participant as having paid
  updatePaid : function (){
    var token = encodeURIComponent($('meta[name=csrf-token]').attr('content'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        paid: true
      }
    }).done(function(data){
      toastr.success(data.member.name + ' heeft betaald');

      $(row).find( 'button.paid' ).removeClass( 'paid btn-warning' ).empty().addClass( 'unpaid btn-primary' ).append( '<i class="fa fa-fw fa-check"></i>' );
      $(row).removeClass('in-debt');

      $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      $( 'input#search' ).select();

      bind_activities();
    }).fail(function(error){
      toastr.error(error.statusText, error.status);
    });
  },

  //Admin marks participant as having not paid
  updateUnpaid : function() {
    var token = encodeURIComponent($('meta[name=csrf-token]').attr('content'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        paid: false
      }
    }).done(function(data){
      toastr.warning(data.member.name + ' heeft nog niet betaald');

      $(row).find( 'button.unpaid' ).removeClass( 'unpaid btn-primary' ).empty().addClass( 'paid btn-warning' ).append( '<i class="fa fa-fw fa-times"></i>' );
      $(row).addClass('in-debt');

      $('#mail').trigger('recipient_unpayed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $( 'input#search' ).select();

      bind_activities();
    }).fail(function(error){
      toastr.error(error.statusText, error.status);
    });
  },

  //Admin updates participant's price
  updatePrice : function (){
    var row = $(this).closest('tr');
    var token = encodeURIComponent($('meta[name=csrf-token]').attr('content'));
    var price = $(this).val().replace(',', '.');

    // If left blank assume 0
    if(!price){
      price = 0;
      $(this).val(0);
    }

    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        price: price
      }
    }).done(function( data ){
      $(row).find('button.unpaid').empty().addClass('paid btn-warning').removeClass('d-none unpaid btn-primary').append('<i class="fa fa-fw fa-times"></i>');
      $(row).find('button.paid').removeClass('d-none');
      $(row).removeClass('in-debt');

      if(price > 0){
        $(row).addClass('in-debt');

        $('#mail').trigger('recipient_unpayed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      }else{
        $(row).find( 'button.paid' ).addClass( 'd-none' );

        $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      }

      toastr.success('Het deelname bedrag is veranderd');
    }).fail(function(){
      toastr.error('Geen verbinding of geen nummer');
    });
  }
};

$(document).on( 'ready page:load turbolinks:load', function(){
  bind_activities();

  //Add participant to activity
  $('#participants').find('input#participant').search().on('selected', function(event, id){
      $.ajax({
        url: '/activities/' + $('#participants-table').attr('data-id') + '/participants',
        type: 'POST',
        data: {
          member: id
        }
      }).done(function( data ){
        participant.add(data);
      }).fail(function(){
        toastr.warning('Deze persoon is al toegevoegd');
      });
  });
});
