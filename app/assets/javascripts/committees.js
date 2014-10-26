// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function bind_committeeMember() {

  // Edit committeeMember function name
  // [PATCH] committeeMembers
  $("#committeeMembers input.function").off('change').on('change', function() {
    var id = $(this).closest('tr').attr('data-id');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));
    var functionName = $(this).val();

    $.ajax({
      url: '/committeeMembers',
      type: 'PATCH',
      data: {
        id: id,
        authenticity_token: token,
        functionName: functionName
      }
    }).done(function(data) {
      console.log(data);

      alert('De functie is veranderd')
    }).fail(function(data) {
      alert('Geen verbinding', 'error');
    });
  });

  // Add new committeeMember using autocomplete on members
  // uses [GET] for autocomplete and [POST] for storing the record
  $("#committeeMembers input.committeeMember")
    .off('focusin keyup').on('focusin keyup', function(e) {
    
    var search = $(this).val();
    var committee = $("#committeeMembers").attr('data-id');
    var dropdown = $(this).closest('tr').find('ul.dropdown-menu');
    var selected = $(dropdown).find('li.active');

    if(e.keyCode == 13){
      if( $(selected).length != 1)
        return;

      var id = $(selected).find('a').attr('data-id');
      var row = $(selected).closest('tr');
      var name = $(selected).find('a').text();
    
      $(selected).closest('#committeeMembers ul').css('display', 'none');
      
      $.ajax({
        url: '/committeeMembers',
        type: 'POST',
        data: {
          member: id,
          committee: committee
        }
      }).done(function( data ){          
        var template = $('script#committeeMember').html();
        var committeeMember = template.format(data.id, data.member_id, name);
        var added = $(committeeMember).insertBefore(row);
       
        $('#committeeMembers input.participant').val('');
        $('#committeeMembers ul.dropdown-menu').empty().css('display', 'none');
        
        $(row).find('input').focus();
        
        bind_committeeMember();
      }).fail(function(){
        $('#committeeMembers input.participant').val('');
        $('#committeeMembers ul.dropdown-menu').empty().css('display', 'none');
        
        $(row).find('input').focus();
                    
        alert('Deze persoon is al toegevoegd', 'warning');
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
        url: '/members/find',
        type: 'GET',
        data: {
          search: search,
          committeeMember: $(dropdown).closest('table').attr('data-id')
        }
      }).done(function( data ){
        $(dropdown).empty();

        for(var item in data){
          var html = "<li><a data-id=" + data[item].id + ">" + data[item].first_name + " " + data[item].infix + " " + data[item].last_name + "</a></li>";
          $(dropdown).append(html);
          $(dropdown).css('display', 'block');
        }
        
        $('#committeeMembers ul.dropdown-menu li a').on('click', function(){
          var id = $(this).attr('data-id');
          var committee = $(this).closest('table').attr('data-id');
          var row = $(this).closest('tr');
          var name = $(this).text();
        
          $(this).closest('#committeeMembers table ul').css('display', 'none');
          
          $.ajax({
            url: '/committeeMembers',
            type: 'POST',
            data: {
              member: id,
              committee: committee
            }
          }).done(function( data ){          
            var template = $('script#committeeMember').html();
            var committeeMember = template.format(data.id, data.member_id, name);
            var added = $(committeeMember).insertBefore(row);
            
            $('#committeeMembers input.committeeMember').val('');
            $('#committeeMembers ul.dropdown-menu').empty().css('display', 'none');
            
            $(row).find('input').focus();
            
            bind_committeeMember();
          }).fail(function(){
            $('#committeeMembers input.committeeMember').val('');
            $('#committeeMembers ul.dropdown-menu').empty().css('display', 'none');
            
            $(row).find('input').focus();
                        
            alert('Deze persoon is al toegevoegd', 'warning');
          });
        })
      }).fail(function(){
        alert('', 'error');
      });
    }
  });

  // Remove committeeMember
  // [DELETE] committeeMembers
  $("#committeeMembers button.destroy").off('click').on('click', function() {
    var row = $(this).closest('tr');
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));

    $.ajax({
      url: '/committeeMembers',
      type: 'DELETE',
      data: {
        id: row.attr('data-id'),
        authenticity_token: token
      }
    }).done(function() {
      alert('commissielid verwijderd', 'success');
      $(row).remove();
    }).fail(function() {
      alert('', 'error')
    });
  });

}

$(document).on('ready page:load', function(){
  bind_committeeMember();
});