$(document).on( 'ready page:load', function(){  
 
  $('.date-input input').on('change', function(){
    var params = {};
    
    params['date'] = $(this).val();
    location.search = $.param(params);
  });
});