// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap

$(document).on('ready page:load', function(){
  $("#menu-close").click(function(e) {
      e.preventDefault();
      $("#sidebar-wrapper").toggleClass("active");
  });
  
  $("#menu-toggle").click(function(e) {
      e.preventDefault();
      $("#sidebar-wrapper").toggleClass("active");
  });
  
  $('.alert .close').on('click', function(){
    $(this).closest('.alert').remove();
  });
  
  $(function() {
      $('a[href*=#]:not([href=#])').click(function() {
          if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') || location.hostname == this.hostname) {
  
              var target = $(this.hash);
              target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
              if (target.length) {
                  $('html,body').animate({
                      scrollTop: target.offset().top
                  }, 1000);
                  return false;
              }
          }
      });
  });
  
  $('select#method').on("change", function(){
    var value = $(this).val();
    
    if(value == 'CONTANT'){
      $('select#bank').attr('disabled', 'disabled').css('background-color', 'rgb(238, 238, 238)').css('color', 'rgb(118, 118, 118)').css('border-color', 'rgb(203, 213, 221)');;
    }else{
      $('select#bank').removeAttr('disabled').removeAttr('style');
    }
  });
  
  $('.copyable .ui-select select').on('change', function(){
    var row = $(this).closest('.row');
    var date = $(row).find('input[type="date"]');
    
    function pad(s) { return (s < 10) ? '0' + s : s; }
    
    if(!$(this).val()){
      $(date).val('');
      return;
    }
    
    if( !$(date).val() ){
      var d = new Date();
      $(date).val( [pad(d.getDate()), pad(d.getMonth()+1), d.getFullYear()].join('-') );
    }
    
  });
  
  
  $('label a.close').on('click', function() {
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
    $('.form-group a.btn.destroy').on('click', function(){
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