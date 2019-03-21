$(document).on('ready page:load turbolinks:load', function(){
  // Alerts for on the frontend, default type is info
  // script#alert is a template in de header file.
  String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) {
      return typeof args[number] != 'undefined' ? args[number] : match;
    });
  };

  window.alert = function(message, type){
    var template = $('template#alert').html();
    var alert = template.format(message, type || 'info');
    $('#toast-container').append(alert).children('.toast:not(.toast-error)').delay(3000).queue(function() {
      $(this).remove();
    });

    $('.toast-close-button').on('click', function(){
      $(this).closest('.toast').remove();
    });
  };

  // Callback handler for menu
  $('.toggle-min').click(function(event){
    event.preventDefault();

    $('#app').children('div').toggleClass('nav-min');
  });

  $('#year').on('change', function(){
    var params = {};

    params.year = $(this).val();
    location.search = $.param(params);
  });

  $('td.dropdown li a').on('click', function(event){
    event.preventDefault();

    $(this).closest('tr').find('input.status').val($(this).closest('li').data('status'))
    $(this).closest('tr').find('td:nth-child(2)').text($(this).text())
  });
});
