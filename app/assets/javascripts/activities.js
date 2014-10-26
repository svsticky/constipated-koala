// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function bind_activity(){
  $('#activities input.price').off('focusout');
  $('#mail #recipients select').off('change');
  $('#mail #recipients input').off('change');
  
  
  // Participant bedrag aanpassen
  // [PATCH] participants
  $('#activities').find('input.price').on('change', function(){
    var row = $(this).closest('tr')
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var price = $(this).val();
    
    // If left blank asume 0
    if(!price){
      price = 0;
      $(this).val(0);
    }
    
    // Make it a bit more pretty
    if(!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));
    
    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: row.attr('data-id'),
        authenticity_token: token,
        price: price
      }
    }).done(function( data ){
      console.log(data)
      
      $('#mail #recipients select').val('edited');
      $(row).find('button.unpaid').empty().addClass('paid btn-warning').removeClass('hidden unpaid btn-primary').append('<i class="fa fa-fw fa-times"></i>');
      $(row).find('button.paid').removeClass('hidden');
      
      $(row).removeClass('red');
      
      if(price > 0)
        $(row).addClass('red');
      else
        $(row).find('button.paid').addClass('hidden');
      
      alert('het deelname bedrag is veranderd');
    }).fail(function( data ){
      alert('geen verbinding of geen nummer', 'error');
    });
  });
  
  setupSearch({
    elem: "#activities",
    searchUrl: "/members/find",
    postUrl: "/participants",
    failMsg: "Deze persoon is al toegevoegd",
    submit: function(data, selected) {
      var template = $('script#activity').html();
      var row = $(selected).closest('tr');

      var name = $(selected).find('a').text();
      var price = $(row).find('td span').text().replace(/€/g, '').replace('-', '');
      var newRow = template.format(data.id, data.member_id, name, price);
  
      var added = $(newRow).insertBefore(row);
      
      if(price > 0)    
        $(added).addClass('red');
      else
        $(added).find('button.paid').addClass('hidden');      

      bind_activities();
      bind_activity();
    },
    format: function(item) {
      return "<li><a data-id=" + item.id + ">"
        + item.first_name + " " + item.infix + " " + item.last_name
        + "</a></li>";
    }
  });
  
  $('#mail #recipients').find('select').on('input change', function(){
    var activity = $(this).closest('form#mail').attr('data-id');    
    var input = $(this).closest('#recipients').find('input');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var recipients = $(this).val();
    
    $.ajax({
      url: '/participants/list',
      type: 'GET',
      data: {
        authenticity_token: token,
        recipients: recipients,
        activity: activity
      }
    }).done(function( data ){
      var recipients = "";
      for (var i in data){
        if( data[i].infix == '')
          recipients += data[i].first_name + ' ' + data[i].last_name + ' <' +   data[i].email + '>, ';
        else
          recipients += data[i].first_name + ' ' + data[i].infix + ' ' + data[i].last_name + ' <' +   data[i].email + '>, ';
      }
      
      $(input).val(recipients);
      alert('geaddresseerden aangepast');
    }).fail(function( data ){
      alert('geen verbinding met de server', 'error');
    });
  });
    
    
  $('#mail #recipients').find('input').on('input change', function(){
    var select = $(this).closest('#recipients').find('select').val('edited');
  });
}

$(document).on('ready page:load', function(){
  bind_activity();

  $('form#mail .ta-toolbar button').on('click', function(){
    var textarea = $('textarea#text');

    switch ( $(this).attr('name') ){
      default :
        alert('test');
        break;
    }
  });

  $('form#mail .mail-actions .btn.btn-primary').on('click', function( e ){
    e.preventDefault();
    
    if(!confirm('Weet je het zeker?'))
      return;
    
    $.ajax({
      url: '/mail',
      type: 'POST',
      data: {
        id: $('form#mail').attr('data-id'),
        recipients: $('form#mail #recipients input#bbc').val(),
        subject: $('form#mail input#onderwerp').val(),
        text: $('form#mail textarea#text').val()
        }
    }).done(function( data ){
      console.log(data)
      alert('mail is verstuurd');
    }).fail(function( data ){
      alert('mail is niet verstuurd', 'error');
    });
  });
});
