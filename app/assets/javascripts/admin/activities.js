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
  update_debt_header: function (paidSum, priceSum) {
    $('#paidsum').html('€' + parseFloat(paidSum).toFixed(2));
    $('#pricesum').html('/ €' + parseFloat(priceSum).toFixed(2));
  },

  //Admin adds a new participant to the activity
  add : function(data){
    var template = $('template#attendee-table-row').html();
    var formattedTemplate = template.format(
        data.id,
        data.member.id,
        data.member.name,
        data.member.email
    );

    var added = $(formattedTemplate).insertBefore('#participants-table tr:last');
    $('.number').html( +$('.number').html() +1 );

    if(data.activity.price > 0)
      $(added).addClass('in-debt');
    else
      $(added).find( 'button.paid' ).addClass( 'hidden' );

    $('#attendeecount').html(data.activity.fullness);
    participant.update_debt_header(data.activity.paid_sum, data.activity.price_sum);
    bind_activities();

    // trigger #mail client to add recipient
    $('#mail').trigger('recipient_added', [ data.id, data.member.name, data.member.email, data.activity.price ]);
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
      if (data.magic_reservists.length > 0) {
        data.magic_reservists.forEach(
          function(item, index, array) {
            $("#reservists-table tbody tr:nth-child(2)").remove();
            participant.add(item, item.name);
          });
      } else {
          // Not already done in participant.add above
        $('#attendeecount').html(data.fullness);
        participant.update_debt_header(data.paid_sum, data.price_sum);
      }

      $('#reservistcount').html(data.reservist_count);

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
      alert(data.member.name + ' is op de deelnemerslijst geplaatst', 'success');
      participant.add(data);

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
    }).done(function(data){
      toastr.success(data.member.name + ' heeft betaald', 'success');

      $(row)
        .find( 'button.paid' )
        .empty()
        .removeClass( 'paid btn-warning red' )
        .addClass( 'unpaid btn-primary' )
        .append( '<i class="fa fa-fw fa-check"></i>' );

      $(row).removeClass('in-debt');
      participant.update_debt_header(data.activity.paid_sum, data.activity.price_sum);

      $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);

      $( 'input#search' ).select();

      bind_activities();
    }).fail(function(){
      toastr.error( '', 'error' );
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
    }).done(function(data){
      alert($(row).find( 'a' ).html() + ' heeft nog niet betaald', 'warning' );

      $(row)
        .find( 'button.unpaid' )
        .empty()
        .addClass( 'paid btn-warning red' )
        .removeClass( 'unpaid btn-primary' )
        .append( '<i class="fa fa-fw fa-times"></i>' );

      $(row).addClass('in-debt');
      participant.update_debt_header(data.activity.paid_sum, data.activity.price_sum);

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
      $(row).removeClass('in-debt');

      if(price > 0){
        $(row).addClass('in-debt');

        $('#mail').trigger('recipient_unpayed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      }else{
        $(row).find( 'button.paid' ).addClass( 'hidden' );

        $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      }

      participant.update_debt_header(data.activity.paid_sum, data.activity.price_sum);

      alert( 'het deelname bedrag is veranderd' );
    }).fail(function( data ){
      alert( 'geen verbinding of geen nummer', 'error' );
    });
  }
};

/*
 * Document load handler
 */
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
        alert( 'Deze persoon is al toegevoegd', 'warning' );
      });
  });

  posterHandlers();

  $('form#mail').mail();

  // 'Enrollable' checkbox toggled
  $('#activity_is_enrollable').on('click', function() {
      $('#participant_limit')[0].disabled = !this.checked;
  });

  $('#activity_is_viewable').on('click', function() {
      $('#activity_is_enrollable')[0].disabled = !this.checked;
      $('#activity_show_on_website')[0].disabled = !this.checked;
      if(!this.checked)
      {
          $('#activity_show_on_website')[0].checked = this.checked;
          $('#activity_is_enrollable')[0].checked = this.checked;
          $('#participant_limit')[0].disabled = !this.checked;
      }
  });

  if($('#activity_is_viewable').length > 0 && $('#activity_is_viewable')[0].checked)
  {
      $('#activity_is_enrollable')[0].disabled = false;
      $('#activity_show_on_website')[0].disabled = false;
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
  $('form .input-group-append .file-input-wrapper input[type="file"]').on('change', function(){
    if( this.files && this.files[0] ){
      $('form .input-group-append .dropdown-toggle').removeClass('disabled');
      $('form input.remove_poster').val('false');
      $('form .input-group input#output').val(this.files[0].name);
    }
  });

  //Handler for removing the poster
  $('form .input-group-append a.remove').on('click', function( e ){
    e.preventDefault();

    $('form .input-group-append .dropdown-toggle').addClass('disabled');
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
