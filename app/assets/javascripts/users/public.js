//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap

$(document).on('ready page:load', function(){

  if( $('.studies .ui-select select:first').find('option:selected').data('masters') ){
    $('.activities').hide();
  }

  $("#menu-close").click(function(e) {
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
    if( $(this).val() == 'CONTANT' ){
      $('select#bank').attr('disabled', 'disabled').css('background-color', 'rgb(238, 238, 238)').css('color', 'rgb(118, 118, 118)').css('border-color', 'rgb(203, 213, 221)');;
    } else {
      $('select#bank').removeAttr('disabled').removeAttr('style');
    }
  });

  $('.studies .ui-select select').on('change', function(){
    if( $(this).find('option:selected').data('masters') ){
      $('.activities').hide();
    } else {
      $('.activities').show();
    }
  });

  setTimeout(function() {
    $('.alert.alert-success').hide();
  }, 3000);

  var jumboHeight = $('.header').outerHeight();

  $(window).scroll(function(e){
    var scrolled = $(window).scrollTop();
    $('.header-bg').css('height', (jumboHeight-scrolled) + 'px');
    $('.header-bg').css('height', (jumboHeight-scrolled) + 'px');
  });

  var callout = $('#callout');
  callout.carousel();

  setInterval(function() {
    callout.carousel('next');
  }, 3000);
});
