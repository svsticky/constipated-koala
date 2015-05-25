// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//
//= require bootstrap-file-input

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
      alert($(row).find('a').html() + ' heeft betaald', 'success');

      $(row).find( 'button.paid' ).empty().removeClass( 'paid btn-warning' ).addClass( 'unpaid btn-primary' ).append( '<i class="fa fa-fw fa-check"></i>' );
      $(row).removeClass( 'red' );
      
      $('#mail').trigger('recipient_payed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
      
      $( 'input#search' ).select();
      
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
      alert($(row).find( 'a' ).html() + ' heeft nog niet betaald', 'warning' );
      
      $(row).find( 'button.unpaid' ).empty().addClass( 'paid btn-warning' ).removeClass( 'unpaid btn-primary' ).append( '<i class="fa fa-fw fa-times"></i>' );
      $(row).addClass( 'red' );
      
      $('#mail').trigger('recipient_unpayed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
            
      $( 'input#search' ).select();
      
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
    
    if( !confirm('Deelname van ' + $(row).find('a').html() + ' verwijderen?') )
      return
    
    $.ajax({
      url: '/participants',
      type: 'DELETE',
      data: {
        id: id,
        authenticity_token: token
      }
    }).done(function(){
      alert($(row).find('a').html() + ' verwijderd', 'warning');
      $(row).remove();
      $('.number').html( $('.number').html() -1 );
      
      $('#mail').trigger('recipient_removed', [ $(row).attr('data-id'), $(row).find('a').html(), $(row).attr('data-email') ]);
            
      $( 'input#search' ).select();
    }).fail(function(){
      alert( '', 'error' );
    });
  });

  // Participant bedrag aanpassen
  // [PATCH] participants
  $('#participants').find('input.price').on('change', function(){
    var row = $(this).closest('tr')
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var price = $(this).val().replace(',', '.');
    
    // If left blank asume 0
    if(!price){
      price = 0;
      $(this).val(0);
    }
    
    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));
    
    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: row.attr( 'data-id' ),
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
  }); 
}
    
$(document).on( 'ready page:load', function(){
  bind_activities();
  
  $('#participants').find('input#participant').search().on('selected', function(event, id, name){
      $.ajax({
        url: '/participants',
        type: 'POST',
        data: {
          member: id,
          activity: $('#participants table').attr('data-id') 
        }
      }).done(function( data ){                          
        var template = $('script#activity').html();
        var activity = template.format(data.id, data.member_id, name, data.email, parseFloat(data.price).toFixed(2) || '');
        var added = $(activity).insertBefore('#participants table tr:last');
        
        $('.number').html( +$('.number').html() +1 );
        
        if(data.price > 0)    
          $(added).addClass( 'red' );
        else
          $(added).find( 'button.paid' ).addClass( 'hidden' ); 
        
        bind_activities();
        
        // trigger #mail client to add recipient
        $('#mail').trigger('recipient_added', [ data.id, name, data.email, data.price ]);
        
        $( '#participants .form-group input#participants' ).focus();
      }).fail(function(){                    
        alert( 'Deze persoon is al toegevoegd', 'warning' );
      });
  });

  $('form .input-group-btn .file-input-wrapper input[type="file"]').on('change', function(){
    if( this.files && this.files[0] ){
      $('form .input-group-btn .dropdown-toggle').removeClass('disabled');  
      $('form input.remove_poster').val('false');
      $('form .input-group input#output').val(this.files[0].name);

      //TODO what todo with the preview, also what do as default
    }
  });

  $('form .input-group-btn a.remove').on('click', function(){
    $('form .input-group-btn .dropdown-toggle').addClass('disabled');  
    $('form .input-group input#output').val('');
    $('form input.remove_poster').val('true');
    
    $('form .file-input-wrapper input[type="file"]').val(null)
    $('form .thumb img').remove();
  });
  
  $('form').on('submit', function(){
    $( this ).find('button[type="submit"].wait').addClass('disabled');
  });
  
  $('form#mail').mail();
  
  if( $('.filtered-search') ){
    $('input#search').on('keyup', function(){
      
      var query = new RegExp( $( this ).val(), 'i');
      
      $( '.filtered-search table' ).each( function( index, table ){
        $( table ).find( 'tbody tr' ).each( function( index, row ){
          
          if( query.test( $( row ).attr( 'data-name' )))
            $( row ).removeClass('hidden');
          else
            $( row ).addClass('hidden');
        });
        
        if( $( table ).find( 'tbody tr' ).not( '.hidden' ).length > 0 )
          $( table ).removeClass('hidden');
        else
          $( table ).addClass('hidden');
      });
    });
  }
});
