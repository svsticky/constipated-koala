$(document).on( 'ready page:load', function(){  
  $( 'form#mail #recipients select' ).off( 'change' );
  $( 'form#mail #recipients input' ).off( 'change' );
  
  $( 'form#mail #recipients' ).find( 'select' ).on( 'input change', function(){
    var activity = $(this).closest( 'form#mail' ).attr( 'data-id' );    
    var input = $(this).closest( '#recipients' ).find( 'input' );
    var token = encodeURIComponent($(this).closest( '.page' ).attr( 'data-authenticity-token' ));
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
        if( data[i].infix == '' )
          recipients += data[i].first_name + ' ' + data[i].last_name + ' <' +   data[i].email + '>, ';
        else
          recipients += data[i].first_name + ' ' + data[i].infix + ' ' + data[i].last_name + ' <' +   data[i].email + '>, ';
      }
      
      $(input).val(recipients);
      alert( 'geaddresseerden aangepast' );
    }).fail(function( data ){
      alert( 'geen verbinding met de server', 'error' );
    });
  });
    
    
  $( 'form#mail #recipients' ).find( 'input' ).on( 'input change', function(){
    var select = $(this).closest( '#recipients' ).find( 'select' ).val( 'edited' );
  });
  
  $( 'form#mail .ta-toolbar button' ).on( 'click', function(){
    var textarea = $( 'textarea#text' );

    switch ( $(this).attr( 'name' ) ){
      default :
        alert( 'test' );
        break;
    }
  });

  $( 'form#mail .mail-actions .btn.btn-primary' ).on( 'click', function( e ){
    e.preventDefault();
    
    if(!confirm( 'Weet je het zeker?' ))
      return;
    
    $.ajax({
      url: '/participants/mail',
      type: 'POST',
      data: {
        id: $( 'form#mail' ).attr( 'data-id' ),
        recipients: $( 'form#mail #recipients input#bbc' ).val(),
        subject: $( 'form#mail input#onderwerp' ).val(),
        text: $( 'form#mail textarea#text' ).val()
        }
    }).done(function( data ){
      console.log(data)
      alert( 'mail is verstuurd' );
    }).fail(function( data ){
      alert( 'mail is niet verstuurd', 'error' );
    });
  });
});