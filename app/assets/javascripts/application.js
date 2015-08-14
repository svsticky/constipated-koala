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

  $( '.page.search .input-group ul.dropdown-menu').find( 'li a' ).on( 'mouseenter', function(){
    $( '.page.search .input-group ul.dropdown-menu').find('li.active').removeClass('active');
    $( this ).addClass('active');
  }).on( 'mousedown', function(){
    var query = $( '.page.search .input-group ul.dropdown-menu:visible').attr('data-query')

    $( '.page.search .input-group input[name=search]' ).val( $( '.page.search .input-group input[name=search]' ).val().replace( query, query.split(':')[0] + ':' + $( this ).attr('data-name') + ' ' ) )

    $( 'ul.dropdown-menu' ).removeAttr('data-query').delay(10).hide(1);
    $( '.page.search .input-group input[name=search]' ).focus();
  });

  $( '.page.search .input-group' ).find( 'input[name=search]' ).on( 'click focus keydown keyup', function( event ){
    var study = /(studie|study):([A-Za-z-]*)/g.exec( $( this ).val() );
    var tag = /(tag):([A-Za-z-]*)/g.exec( $( this ).val() );

    var dropdown, selected;

    if ( study != null && this.selectionStart >= study.index && this.selectionStart <= study.index + study[0].length ) {
      dropdown = $( '.page.search .input-group' ).find( 'ul.dropdown-menu[name=studies]');
      selected = $( '.page.search .input-group ul.dropdown-menu[name=studies]').find( 'li.active' );
      $( dropdown ).show();
    }else{
      study = null;
      $( 'ul.dropdown-menu[name=studies]' ).delay(10).hide(1);
    }

    if ( tag != null && this.selectionStart >= tag.index && this.selectionStart <= tag.index + tag[0].length ) {
      dropdown = $( '.page.search .input-group' ).find( 'ul.dropdown-menu[name=tags]');
      selected = $( '.page.search .input-group ul.dropdown-menu[name=tags]').find( 'li.active' );
      $( dropdown ).show();
    }else{
      tag == null;
      $( 'ul.dropdown-menu[name=tags]' ).delay(10).hide(1);
    }

    //$( dropdown ).css('left', study.index * 6 + 'px');

    if( study != null )
      $( dropdown).attr( 'data-query', study[0] )
    if( tag != null )
      $( dropdown).attr( 'data-query', tag[0] )

    if( event.keyCode == 13 || event.keyCode == 9){
      if( $( 'ul.dropdown-menu:visible').length > 0 )
        event.preventDefault();

      if( $( selected ).length != 1 )
        return

        if( study != null )
          $( this ).val( $( this ).val().replace( study[0], study[1] + ':' + $( selected ).find( 'a' ).attr('data-name') + ' ' ) )
        if( tag != null )
          $( this ).val( $( this ).val().replace( tag[0], tag[1] + ':' + $( selected ).find( 'a' ).attr('data-name') + ' ' ) )

        $( 'ul.dropdown-menu' ).removeAttr('data-query').delay(10).hide(1);

     }else if( event.keyCode == 40 && event.type != 'keyup' ){

       $( selected ).removeClass( 'active' );
       selected = $( selected ).next();

       if( $( selected ).length == 0 )
         selected = $( dropdown ).find( 'li:first' );
       $( selected ).addClass( 'active' );


       event.preventDefault();

     }else if( event.keyCode == 38 && event.type != 'keyup' ){

       $( selected ).removeClass( 'active' )
       selected = $( selected ).prev();

       if( $( selected ).length == 0 )
         selected = $( dropdown ).find( 'li:last' );
       $( selected ).addClass( 'active' );

       event.preventDefault();

     }else if( study != null && event.type != 'keyup' ){
       var items = $.unique( $( '.page.search .input-group ul.dropdown-menu[name=studies] li a[data-name!=' + study[2] + '][data-name^=' + study[2] + '], .page.search .input-group ul.dropdown-menu[name=studies] li a[data-code!=' + study[2] + '][data-code^=' + study[2] + ']' ));

       if( $(items).length != 1 )
         return

       $( '.page.search .input-group ul.dropdown-menu[name=studies] li').removeClass( 'active' )
       $( items ).parent('li').addClass( 'active' );
     }else if( tag != null && event.type != 'keyup'  ){
      var items = $( '.page.search .input-group ul.dropdown-menu[name=tags] li a[data-name!=' + tag[2] + '][data-name^=' + tag[2] + ']' );

      if( $(items).length != 1 )
        return

      $( '.page.search .input-group ul.dropdown-menu[name=tags] li').removeClass( 'active' )
      $( items ).parent('li').addClass( 'active' );
     }
  }).on( 'focusout', function(){
    $( '.page.search .input-group' ).find( 'ul.dropdown-menu' ).hide(1);
  });;

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
