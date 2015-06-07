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
  
  window.alert = function(message, type){
    type = type || 'info';
    
    var template = $('script#alert').html();
    var alert = template.format(message, type);
    $('#toast-container').append(alert).find('.toast:not(.toast-error)').delay(3000).queue(function() {
      $(this).remove();
    });
    
    $('.toast-close-button').one('click', function(){
      $(this).closest('.toast').remove();
    })
  }
});
