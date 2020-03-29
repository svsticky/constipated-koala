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
//= require jquery/dist/jquery.min
//= require jquery-ujs/src/rails
//= require bootstrap/dist/js/bootstrap.bundle.min.js
//
//= require dropdown
//= require editor
//= require mail
//
//= require clipboard/dist/clipboard.min
//= require turbolinks/dist/turbolinks
//= require toastr/build/toastr.min
//
//= require_tree ./application

$(document).on('ready page:load turbolinks:load', function(){

  // Alerts for on the frontend, default type is info
  // script#alert is a template in de header file.
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) {
      return typeof args[number] != 'undefined' ? args[number] : match;
    });
  };


  // Select specific year in multiplje views
  $('.card-header > select.custom-select').on('change', function(){
    var params = {};

    params.year = $(this).val();
    location.search = $.param(params);
  });

  // Ask for confirmation on data-method=delete
  $('.btn[data-method=delete]').on('click', function () {
    return confirm('Weet u het zeker?');
  });
});
