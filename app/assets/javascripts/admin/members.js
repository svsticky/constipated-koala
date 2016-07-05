// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function(){

  $('.education label a.close').bind( 'click', function() {
    var row = $('.education .copyable:last').clone().insertAfter($('.education .copyable:last'));

    //member[educations_attributes][39][name_id]
    var name = $(row).find('select').attr('name');
    var id = name.match(/\[(-?\d*\d+)\]/)[1];

    if(+id < 0)
      id = +id - 1;
    else
      id = -1;

    //replace all inputs and select name and id?
    $(row).find('input').each(function() {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)\]/, '[' + id + ']'));
    });

    $(row).find('select').each(function() {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)\]/, '[' + id + ']'));
    });

    destroy(row);
  });

  function destroy( el = null ){
    var selector = $('.education .form-group a.btn.destroy');

    if( el !== undefined && el !== null)
      selector = $(el).find('a.btn.destroy');

    $( selector ).bind( "click", function(){
      var row = $( this ).closest('.form-group');

      var destroy = $( row ).find('input.destroy');

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

  destroy(null);
});
