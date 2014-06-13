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
//= require_tree .

$( document ).ready(function() {
	if( document.cookie.search('nav-min') >= 0 )
		$('#app div').addClass('nav-min');

	$('.toggle-min').click(function(event){
	  event.preventDefault();
	  
	  $('#app div').toggleClass('nav-min');
	  
	  if( $('#app div').hasClass('nav-min') ){
	  	document.cookie = 'nav-min=true; path=/;';
	  }else{
	  	document.cookie = 'nav-min=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/;';
	  }
	  
	});
});