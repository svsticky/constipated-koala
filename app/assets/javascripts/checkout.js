// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function(){
  $('#activities').find('input.participant').on('focusout', function(){
    var dropdown = $(this).closest('tr').find('ul.dropdown-menu');
    $( dropdown ).empty().css('display', 'none');
  });
  
  $('div.cards ul.list-group button.activate').bind( 'click', function() {
    var button = $( this );
    var row = $( this ).closest('.list-group-item');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    
    //disable
    $( button ).attr('disabled', 'disabled');
    
    $.ajax({
      url: '/checkout/card',
      type: 'PATCH',
      data: {
        uuid: $( row ).attr('data-uuid'),
        authenticity_token: token
      }
    }).done(function(){          
      alert('kaart geactiveerd', 'success');
      $( row ).remove();
    }).fail(function(){                  
      alert('kaart is niet geactiveerd', 'error');
      $( button ).removeAttr('disabled');
    });
  });
});