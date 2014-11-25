// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function(){
  $('#activities').find('input.participant').on('focusout', function(){
    var dropdown = $(this).closest('tr').find('ul.dropdown-menu');
    $( dropdown ).empty().css('display', 'none');
  });
  
  $('div#cards ul.list-group button.activate').bind( 'click', function() {
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
  
  $('#credit').find('input.participant').on('focusout', function(){
    var dropdown = $(this).closest('.panel-body').find('ul.dropdown-menu');
    $( dropdown ).empty().css('display', 'none');
  });
  
  // Add new participant using autocomplete on members
  // uses [GET] for autocomplete and [POST] for storing the record
  $('#credit').find('input.participant').on('focusin keyup', function( e ){
    var search = $(this).val();
    var dropdown = $(this).closest('.panel-body').find('ul.dropdown-menu');
    var selected = $(dropdown).find('li.active');

    if(e.keyCode == 13){
      if( $(selected).length != 1)
        return;
      
      var id = $(selected).find('a').attr('data-id');
    
      $( dropdown ).empty().css('display', 'none');
      $( this ).attr('disabled', 'disabled').val( $( selected ).find('a').html() );
      $( '#credit .form-group.participant').attr('data-id', id).removeClass('col-md-12').addClass('col-md-4');
      
      $( '#credit .form-group').css('display', 'block');
      $( '#credit input.amount').focus();
      
      e.preventDefault();
    }else if(e.keyCode == 40){
      $(selected).removeClass('active');
      selected = $(selected).next();
      
      if( $(selected).length == 0 )
        selected = $(dropdown).find('li:first');
      $(selected).addClass('active');
       
      e.preventDefault();
    }else if(e.keyCode == 38){
      $(selected).removeClass('active')
      selected = $(selected).prev();
      
      if( $(selected).length == 0 )
        selected = $(dropdown).find('li:first');
      $(selected).addClass('active');
      
      e.preventDefault();
    }else if(search.length > 2){
      $.ajax({
        url: '/participants',
        type: 'GET',
        data: {
          search: search
        }
      }).done(function( data ){
        $(dropdown).empty();

        for(var item in data){
          var html = "<li><a data-id=" + data[item].id + ">" + data[item].first_name + " " + data[item].infix + " " + data[item].last_name + "</a></li>";
          $(dropdown).append(html);
          $(dropdown).css('display', 'block');
        }
        
        $('#activities ul.dropdown-menu li a').on('click', function(){      
          var id = $( this ).attr('data-id');
              
          $( this ).closest( 'input.participant' ).attr('disabled', 'disabled').val( $( selected ).find('a').html() );
          $( dropdown ).empty().css('display', 'none');
          
          //go to a screen where a fund can be added
          
          
        })
      }).fail(function(){
        alert('', 'error');
      });
    }
  });
  
  $('#credit').find('form.form-inline').on('submit', function( e ){
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    
    $.ajax({
      url: '/checkout/transaction',
      type: 'PATCH',
      data: {
        id: $( '#credit .form-group.participant').attr('data-id'),
        amount: $( '#credit .form-group.amount input').val().replace(',', '.'),
        authenticity_token: token
      }
    }).done(function(){          
      alert('checkout opgewaardeerd', 'success');
      
      //toevoegen aan de lijst
      
      //formulier terugveranderen
      $( '#credit .form-group.participant input').removeAttr('disabled').val('');
      $( '#credit .form-group:not(.participant)').css('display', 'none');
      $( '#credit .form-group.participant').removeAttr('data-id').removeClass('col-md-4').addClass('col-md-12');
      $( '#credit input.particpant').focus();
      
    }).fail(function(){                  
      alert('checkout is niet opgewaardeerd', 'error');
    });
      
    e.preventDefault();
  });
});