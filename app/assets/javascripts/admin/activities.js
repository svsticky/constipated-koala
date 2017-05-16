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

  // Admin marks participant as having not paid
  // [PATCH] participants
  $('#participants').find('button.unpaid').on('click', participant.updateUnpaid);

  // Admin deletes participant from activity
  // [DELETE] participants
  $('#participants button.destroy').on('click', participant.delete);

  $('#participants button.toparticipant').on('click', participant.upgrade);

  // Admin updates participant's price
  // [PATCH] participants
  $('#participants').find('input.price').on('change', participant.updatePrice);
}

/*
 * Participant namespace containing all participant related functions
 */
var participant = {
  //Update counts in the table headers
  updateCounts : function(){
    attendees = $('#participants-table tbody tr').length - 2; //-2 because of the add_participant row and of the header
    reservists = $('#reservists-table tbody tr').length - 1; //-1 because of the header

    $('#attendeecount').html(attendees);
    $('#reservistcount').html(reservists);
  },

  //Admin adds a new participant to the activity
  add : function(data){
    var template = $('template#attendee-table-row').html();
    var activity = template.format(data.id, data.member_id, data.name, data.email);
    var added = $(activity).insertBefore('#participants-table tr:last');
    $('.number').html( +$('.number').html() +1 );

    if(data.price > 0)
      $(added).addClass( 'red' );
    else
      $(added).find( 'button.paid' ).addClass( 'hidden' );

    participant.updateCounts();
    bind_activities();

    // trigger #mail client to add recipient
    $('#mail').trigger('recipient_added', [ data.id, name, data.email, data.price ]);

    $( '#participants .form-group input#participants' ).focus();
  },

  //Admin deletes participant from activity
  delete : function (){
    var row = $(this).closest('tr');
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));

    if( !confirm('Deelname van ' + $(row).find('a').html() + ' verwijderen?') )
      return;

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'DELETE',
      data: {
        authenticity_token: token
      }
    }).done(function(data){
      alert($(row).find('a').html() + ' verwijderd', 'warning');
      $(row).remove();

      //Move reservist to attendees if applicable
      if (data !== null) {
        data.forEach(
          function(item, index, array) {
            $("#reservists-table tbody tr:nth-child(2)").remove();
            participant.add(item, item.name);
          });
      } else {
        participant.updateCounts(); //Already executed in participant.add
      }

      $('#mail').trigger('recipient_removed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $( 'input#search' ).select();
    }).fail(function(){
      alert( '', 'error' );
    });
  },

  // Upgrade from reservists to participants by admin
  upgrade : function (){
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        reservist: false
      }
    }).done(function(data){
      var name = $(row).find('a').html();
      alert(name + ' is op de deelnemerslijst geplaatst', 'success');

      var rowdata = {
        id: $(row).data('id'),
        email: $(row).data('email'),
        name: name,
        notes: $(row).find('.notes-td')[0].innerHTML,
      };
      participant.add(rowdata);

      $(row).remove();

      bind_activities();
    }).fail(function(){
      alert( '', 'error' );
    });
  },

  //Admin marks participant as having paid
  updatePaid : function (){
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        paid: true
      }
    }).done(function(){
      alert($(row).find('a').html() + ' heeft betaald', 'success');

      $(row)
        .find( 'button.paid' )
        .empty()
        .removeClass( 'paid btn-warning red' )
        .addClass( 'unpaid btn-primary' )
        .append( '<i class="fa fa-fw fa-check"></i>' );

      $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $( 'input#search' ).select();

      bind_activities();
    }).fail(function(){
      alert( '', 'error' );
    });
  },

  //Admin marks participant as having not paid
  updateUnpaid : function() {
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');

    $.ajax({
      url: '/activities/' + row.attr('data-activities-id') + '/participants/' + row.attr( 'data-id' ),
      type: 'PATCH',
      data: {
        authenticity_token: token,
        paid: false
      }
    }).done(function(){
      alert($(row).find( 'a' ).html() + ' heeft nog niet betaald', 'warning' );

      $(row)
        .find( 'button.unpaid' )
        .empty()
        .addClass( 'paid btn-warning red' )
        .removeClass( 'unpaid btn-primary' )
        .append( '<i class="fa fa-fw fa-times"></i>' );

      $('#mail').trigger('recipient_unpayed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $( 'input#search' ).select();

      bind_activities();
    }).fail(function(){
      alert( '', 'error' );
    });
  },

  //Admin updates participant's price
  updatePrice : function (){
    var row = $(this).closest('tr');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
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
      $(row).find('button.unpaid').empty().addClass('paid btn-warning').removeClass('hidden unpaid btn-primary').append('<i class="fa fa-fw fa-times"></i>');
      $(row).find('button.paid').removeClass('hidden');
      $(row).removeClass( 'red' );

      if(price > 0){
        $(row).addClass( 'red' );

        $('#mail').trigger('recipient_unpayed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      }else{
        $(row).find( 'button.paid' ).addClass( 'hidden' );

        $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      }

      alert( 'het deelname bedrag is veranderd' );
    }).fail(function( data ){
      alert( 'geen verbinding of geen nummer', 'error' );
    });
  }
};

/*
 * Document load handler
 */
$(document).on( 'ready page:load', function(){
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
        alert( 'Deze persoon is al toegevoegd', 'warning' );
      });
  });

  posterHandlers();

  $('form#mail').mail();

  // 'Enrollable' checkbox toggled
  $('#is_enrollable').on('click', function() {
      $('#participant_limit')[0].disabled = !this.checked;
  });

  $('#is_viewable').on('click', function() {
      $('#is_enrollable')[0].disabled = !this.checked;
      if(!this.checked)
      {
          $('#is_enrollable')[0].checked = this.checked;
          $('#participant_limit')[0].disabled = !this.checked;
      }
  });

    if($('#is_viewable').length > 0 && $('#is_viewable')[0].checked)
    {
        $('#is_enrollable')[0].disabled = false;
    }

  // Add confirmation dialog only when changing participants limit
  $('#participant_limit').on('change', function() {
    $('.btn.btn-success.wait[type="submit"]').attr('data-confirm', "Activiteit opslaan?");
  });
});

/*
 * Contains the poster related handlers
 */
function posterHandlers(){
  //Update poster field when uploading a poseter
  $('form .input-group-btn .file-input-wrapper input[type="file"]').on('change', function(){
    if( this.files && this.files[0] ){
      $('form .input-group-btn .dropdown-toggle').removeClass('disabled');
      $('form input.remove_poster').val('false');
      $('form .input-group input#output').val(this.files[0].name);
    }
  });

  //Handler for removing the poster
  $('form .input-group-btn a.remove').on('click', function(){
    $('form .input-group-btn .dropdown-toggle').addClass('disabled');
    $('form .input-group input#output').val('');
    $('form input.remove_poster').val('true');

    $('form .file-input-wrapper input[type="file"]').val(null);
    $('form .thumb img').remove();
  });

  //Handler for uploading the poster (keep user waiting)
  $('form').on('submit', function(){
    $( this ).find('button[type="submit"].wait').addClass('disabled');
  });
}
