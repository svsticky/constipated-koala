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

  setupSearch({
    elem: "#committeeMembers",
    searchUrl: "/members/find",
    postUrl: "/committeeMembers",
    failMsg: "Deze persoon is al toegevoegd",
    submit: function(data, selected) {
      var template = $('script#committeeMember').html();
      var name = $(selected).find('a').text();
      var newRow = template.format(data.id, data.member_id, name);

      var row = $(selected).closest('tr');
      $(newRow).insertBefore(row);

      bind_committeeMember();
    },
    format: function(item) {
      return "<li><a data-id=" + item.id + ">"
        + item.first_name + " " + item.infix + " " + item.last_name
        + "</a></li>";
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