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


function activities(){
  //reset all binds
  $('#activities button').off('click');

  // Activiteiten betalen met een async call
  // [PATCH] participants
  $('#activities').find('button.paid').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');
    
    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        paid: true
      }
    }).done(function(){
      alert('activiteit is betaald', 'success');
      
      $(row).find('button.paid').empty().removeClass('paid btn-warning').addClass('unpaid btn-primary').append('<i class="fa fa-fw fa-check"></i>');
      $(row).removeClass('red');
      
      activities();
    }).fail(function(){
      alert('', 'error');
    });
  });
  
  // Activiteiten op niet betaald zetten
  // [PATCH] participants  
  $('#activities').find('button.unpaid').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');
    
    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        paid: false
      }
    }).done(function(){
      alert('activiteit moet nog betaald worden', 'warning');
      
      $(row).find('button.unpaid').empty().addClass('paid btn-warning').removeClass('unpaid btn-primary').append('<i class="fa fa-fw fa-times"></i>');
      $(row).addClass('red');
      
      activities();
    }).fail(function(){
      alert('', 'error');
    });
  });
  
  // Participant bedrag aanpassen
  // [PATCH] participants
  $('#activities').find('.price').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var price = 12;
    
    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        price: price,
        paid: false
      }
    }).done(function(){
      alert('het deelname bedrag is veranderd');
    }).fail(function(){
      alert('', 'error');
    });
  });

  // Deelname aan activiteiten verwijderen
  // [DELETE] participants
  $('#activities button.destroy').on('click', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var row = $(this).closest('tr');
    
    $.ajax({
      url: '/participants',
      type: 'DELETE',
      data: {
        id: id,
        authenticity_token: token
      }
    }).done(function(){
      alert('deelname verwijderd', 'success');
      $(row).remove();
    }).fail(function(){
      alert('', 'error');
    });
  });

}
  
$(document).on('ready page:load', function(){

  activities();
  
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
  
  $('#app .alert .close').on('click', function(){
    $(this).closest('.alert').remove();
  })
});