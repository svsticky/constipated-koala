// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function(){

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
      
    //if removed set new one to be active
    $( row ).find('input').removeAttr('disabled');
    $( row ).find('select').removeAttr('disabled').removeAttr('style');
    $( row ).find('input.destroy').val("false")
    $( row ).find('a.btn.destroy').html("<span class='fa fa-trash-o'></span>");
    destroy();

    //replace all inputs and select name and id?
    $(row).find('input').each(function() {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)\]/, '[' + id + ']'));
    });
    
    $(row).find('select').val('').attr("name", $(row).find('select').attr("name").replace(/\[(-?\d*\d+)\]/, '[' + id + ']'));
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