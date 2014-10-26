function setupSearch(args) {
  var $elem = $(args.elem);
  var searchUrl = args.searchUrl;
  var postUrl = args.postUrl;
  var failMsg = args.failMsg;
  var submit = args.submit;
  var format = args.format;

  function clearBox() {
    $elem.find('input.searchBox').val('');
    $elem.find('ul.dropdown-menu').empty().css('display', 'none');
    $elem.find('input.searchBox').focus();
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
      submit(data, selected);
      clearBox();
    }).fail(function(){
      clearBox();
      alert(failMsg, 'warning');
    });    
  }

  $elem.find("input.searchBox").off('focusin keyup').on('focusin keyup', function(e) {
    
    var search = $(this).val();
    var dropdown = $(this).closest('tr').find('ul.dropdown-menu');
    var selected = $(dropdown).find('li.active');

    if(e.keyCode == 13){
      if( $(selected).length != 1)
        return;
   
      sendPost(selected);
      
      e.preventDefault();
    } else if(e.keyCode == 38 || e.keyCode == 40){
      $(selected).removeClass('active');
      if (e.keyCode == 40)
        selected = $(selected).next();
      else
        selected = $(selected).prev();
      
      if( $(selected).length == 0 )
        selected = $(dropdown).find('li:first');
      $(selected).addClass('active');
       
      e.preventDefault();
    }else if(search.length > 2){
      $.ajax({
        url: searchUrl,
        type: 'GET',
        data: {
          search: search
        }
      }).done(function( data ){
        $(dropdown).empty();

        for(var item in data){
          $(dropdown).append(format(data[item]));
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