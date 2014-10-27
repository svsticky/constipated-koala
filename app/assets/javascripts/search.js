function setupSearch(args) {
  var $elem = $(args.elem);
  var searchUrl = args.searchUrl;
  var postUrl = args.postUrl;
  var failMsg = args.failMsg;
  var submit = args.submit;
  var format = args.format;
  var emptyBox = args.emptyBox;
  if (emptyBox == undefined)
    emptyBox = true;

  function clearBox() {
    $elem.find('ul.dropdown-menu').empty().css('display', 'none');
    if (emptyBox) {
      $elem.find('input.searchBox').val('');
      $elem.find('input.searchBox').focus();
    }
  }

  // Post the selected item
  function sendPost(selected) {
    var searchId = $(selected).find('a').attr('data-id');
    var elemId = $elem.attr('data-id');
    var name = $(selected).find('a').text();

    $(selected).closest('ul').css('display', 'none');

    $.ajax({
      url: postUrl,
      type: 'POST',
      data: {
        searchId: searchId,
        id: elemId
      }
    }).done(function( data ){
      clearBox();
      submit(data, selected);
    }).fail(function(){
      clearBox();
      alert(failMsg, 'warning');
    });    
  }

  $elem.find("input.searchBox").off('focusin keyup').on('focusin keyup', function(e) {
    
    var search = $(this).val();
    var dropdown = $elem.find('ul.dropdown-menu');
    var selected = $(dropdown).find('li.active');

    if(e.keyCode == 13){ // Enter
      if( $(selected).length != 1) // Exactly 1 list element active
        return;
   
      sendPost(selected);
      
      e.preventDefault();
    } else if(e.keyCode == 38 || e.keyCode == 40){ // Up/down arrow
      $(selected).removeClass('active');
      if (e.keyCode == 40)
        selected = $(selected).next();
      else
        selected = $(selected).prev();
      
      if( $(selected).length == 0 )
        selected = $(dropdown).find('li:first');
      $(selected).addClass('active');
       
      e.preventDefault();
    } else if (search.length > 2) { // Load suggestions
      $.ajax({
        url: searchUrl,
        type: 'GET',
        data: {
          search: search
        }
      }).done(function( data ){
        $(dropdown).empty();

        for(var item in data){
          var html = "<li><a data-id=" + data[item].id + ">" + format(data[item]) + "</a></li>";
          $(dropdown).append(html);
          $(dropdown).css('display', 'block');
        }

        $elem.find('ul.dropdown-menu li a').on('click', function(){
          sendPost(this.parentNode);
        })
      }).fail(function(){
        alert('', 'error');
      });
    }
  });
}