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
  var masters = ["5", "6" , "7", "8"];

  if( $.inArray( $('.studies .ui-select select:first').val(), masters ) != -1 ){
    $('.bachelor').hide();
    $('.bachelor input').attr('disabled','disabled');
  }

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
  
  $('select#method').on("change", function(){
    var value = $(this).val();
    
    if( value == 'CONTANT' ){
      $('select#bank').attr('disabled', 'disabled').css('background-color', 'rgb(238, 238, 238)').css('color', 'rgb(118, 118, 118)').css('border-color', 'rgb(203, 213, 221)');;
    } else {
      $('select#bank').removeAttr('disabled').removeAttr('style');
    }
  });
  
  $('.studies .ui-select select').on('change', function(){
    if( $.inArray( $(this).val(), masters ) != -1 ){
      $('.bachelor').hide();
      $('.bachelor input').attr('disabled','disabled');
    } else {
      $('.bachelor input[name!="activities\[lidmaatschap\]"]').removeAttr('disabled');
      $('.bachelor').show();
    }
  
    //vul automatisch de datum in
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
});