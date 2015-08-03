//
//= require bootstrap-file-input

$(document).on( 'ready page:load', function(){  
 
  $('.date-input input').on('change', function(){
    var params = {};
    
    params['date'] = $(this).val();
    location.search = $.param(params);
  });
  
  $('form').on('submit', function(){
    $( this ).find('button[type="submit"].wait').addClass('disabled');
  });
});