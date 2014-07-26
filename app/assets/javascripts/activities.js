// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function bind_activity(){
  $('#activities input.price').off('focusout');
  $('#activities input.participant').off('focusin keyup');
  
  // Participant bedrag aanpassen
  // [PATCH] participants
  $('#activities').find('input.price').on('focusout', function(){
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var price = $(this).val();
    
    $.ajax({
      url: '/participants',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        price: price
      }
    }).done(function( data ){
      alert('het deelname bedrag is veranderd');
    }).fail(function( data ){
      alert('geen verbinding of geen nummer', 'error');
    });
  });
  
  // Add new participant using autocomplete on members
  // uses [GET] for autocomplete and [POST] for storing the record
  $('#activities').find('input.participant').on('focusin keyup', function( e ){
    var search = $(this).val();
    var dropdown = $(this).closest('tr').find('ul.dropdown-menu');
    var selected = $(dropdown).find('li.active');

    if(e.keyCode == 13){
      if( $(selected).length != 1)
        return;
      
      var id = $(selected).find('a').attr('data-id');
      var activity = $(selected).closest('table').attr('data-id');
      var row = $(selected).closest('tr');
      var name = $(selected).find('a').text();
    
      $(selected).closest('#activities table ul').css('display', 'none');
      
      $.ajax({
        url: '/participants',
        type: 'POST',
        data: {
          member: id,
          activity: activity
        }
      }).done(function( data ){          
        var template = $('script#activity').html();
        var activity = template.format(data.id, data.member_id, name, $(row).find('td span').text());
        $(activity).insertBefore(row).addClass('red');
        
        //TODO niet rood als het niks kost en ook de paid knop niet tonen
        
        $('#activities input.participant').val('');
        $('#activities ul.dropdown-menu').empty().css('display', 'none');
        
        $(row).find('input').focus();
        
        bind_activities();
        bind_activity();
      });

      
      e.preventDefault();
    }else if(e.keyCode == 40){
      $(selected).removeClass('active');
      selected = $(selected).next();
      
      if( $(selected).length == 0 )
        selected = $(dropdown).find('li:first');
      $(selected).addClass('active');
       
      e.preventDefault();
    }else if(e.keyCode == 38){
      $(selected).removeClass('active')
      selected = $(selected).prev();
      
      if( $(selected).length == 0 )
        selected = $(dropdown).find('li:first');
      $(selected).addClass('active');
      
      e.preventDefault();
    }else if(search.length > 2){
      $.ajax({
        url: '/participants',
        type: 'GET',
        data: {
          search: search
        }
      }).done(function( data ){
        $(dropdown).empty();

        for(var item in data){
          var html = "<li><a data-id=" + data[item].id + ">" + data[item].first_name + " " + data[item].infix + " " + data[item].last_name + "</a></li>";
          $(dropdown).append(html);
          $(dropdown).css('display', 'block');
        }
        
        $('#activities ul.dropdown-menu li a').on('click', function(){
          var id = $(this).attr('data-id');
          var activity = $(this).closest('table').attr('data-id');
          var row = $(this).closest('tr');
          var name = $(this).text();
        
          $(this).closest('#activities table ul').css('display', 'none');
          
          $.ajax({
            url: '/participants',
            type: 'POST',
            data: {
              member: id,
              activity: activity
            }
          }).done(function( data ){          
            var template = $('script#activity').html();
            var activity = template.format(data.id, data.member_id, name, $(row).find('td span').text());
            $(activity).insertBefore(row).addClass('red');
            
            //TODO niet rood als het niks kost en ook de paid knop niet tonen
            
            $('#activities input.participant').val('');
            $('#activities ul.dropdown-menu').empty().css('display', 'none');
            
            $(row).find('input').focus();
            
            bind_activities();
            bind_activity();
          });
        })
      }).fail(function(){
        alert('', 'error');
      });
    }
  });
}

$(document).on('ready page:load', function(){
  bind_activity();
});