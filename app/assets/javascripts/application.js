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
//
//= require dropdown
//= require editor
//= require mail
//
//= require turbolinks
//= require bootstrap

$(document).on('ready page:load', function(){
  // Alerts for on the frontend, default type is info
  // script#alert is a template in de header file.
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) {
      return typeof args[number] != 'undefined'
        ? args[number]
        : match
      ;
    });
  };

  $('.button.btn[data-method=delete]').on('click', function () {
    return confirm('Weet u het zeker?');
  });

  $('footer.table-footer .pagination-container li a[data-offset]').bind( 'click', function(e) {
    var params = {};

    if( $('footer.table-footer .page-num-info').attr('data-search') ) {
      params['search'] = $('footer.table-footer .page-num-info').attr('data-search');
      params['all'] = $('footer.table-footer .page-num-info').attr('data-all');
    }

    params['limit'] = $('footer.table-footer .page-num-info').attr('data-limit');
    params['offset'] = $(this).attr('data-offset');

    e.preventDefault();
    location.search = $.param(params);
  });

  $('footer.table-footer .pagination-container li.scroll a').bind( 'click', function(e) {

  });

  $('footer.table-footer .page-num-info select').bind( 'change', function() {
    var params = {}, limit = $(this).val();
    $('footer.table-footer .page-num-info').attr('data-limit', limit);

    if( $('footer.table-footer .page-num-info').attr('data-search') ) {
      params['search'] = $('footer.table-footer .page-num-info').attr('data-search');
      params['all'] = $('footer.table-footer .page-num-info').attr('data-all');
    }

    params['limit'] = limit;
    params['offset'] = $('footer.table-footer .pagination-container li.active a').attr('data-offset');
    location.search = $.param(params);
  });

/*
  window.confirm = function(){
    alert(arguments[0]);

    event.preventDefault();
    return false;
  }
*/

  window.alert = function(message, type){
    var template = $('script#alert').html();
    var alert = template.format(message, type || 'info');
    $('#toast-container').append(alert).find('.toast:not(.toast-error)').delay(3000).queue(function() {
      $(this).remove();
    });

    $('.toast-close-button').one('click', function(){
      $(this).closest('.toast').remove();
    })
  }

  $('#app .alert .close').on('click', function(){
    $(this).closest('.alert').remove();
  });

  //menu navigation
  var width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
  if( width > 768 && document.cookie.search('nav-min') >= 0 )
      $('#app div').addClass('nav-min');

  $('.toggle-min').click(function(event){
    event.preventDefault();

    $('#app div').toggleClass('nav-min');

    if( $('#app div').hasClass('nav-min') ){
      document.cookie = 'nav-min=true; path=/;';
    }else{
      document.cookie = 'nav-min=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/;';
    }

    $('#nav li').removeClass('open');
    $('#nav li').children('.sub-nav').css('display', 'none');
  });

  $('.year .ui-select select').on('change', function(){
    var params = {};

    params['year'] = $(this).val();
    location.search = $.param(params);
  });
});
