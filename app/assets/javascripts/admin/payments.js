$(document).on('ready page:load', function(){

  //Initialise clipboard-rails
  var clip = new Clipboard('.btn-clipboard', {
    text: function(trigger) {
      return getWhatsappText(trigger.getAttribute('data-texturl'));
    }
  });

  //Update search
  if( $('.filtered-search') ){
    $('input#search').on('keyup', function(){

      var query = new RegExp( $( this ).val(), 'i');

      $( '.filtered-search table' ).each( function( index, table ){
        $( table ).find( 'tbody tr' ).each( function( index, row ){

          if( query.test( $( row ).attr( 'data-name' )))
            $( row ).removeClass('hidden');
          else
            $( row ).addClass('hidden');
        });

        if( $( table ).find( 'tbody tr' ).not( '.hidden' ).length > 0 )
          $( table ).removeClass('hidden');
        else
          $( table ).addClass('hidden');
      });
    });
  }
});

//Requests whatsapp message from server for member
function getWhatsappText (url) {
  return $.ajax({
    url: url,
    success: function() {
      alert('Bericht gekopieerd naar klembord', 'success');
    },
    error: function() {
      alert('Bericht kon niet worden opgehaald', 'error');
    },
    async: false
  }).responseText;
}
