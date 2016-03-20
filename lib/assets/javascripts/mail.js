(function( $ ){

  $.fn.mail = function( options ){
    var opts = $.extend({}, $.fn.mail.defaults, options);
    var form = $( this );

    var recipients, debtors;

    return this.each(function(){

      // activate wysiwyg editor
      $( this ).editor({ htmlarea: opts.message });

      // fill the lists of recipients and debtors
      recipients = $.fn.mail.list( '#participants table tr:not(:last-child)' );
      debtors = $.fn.mail.list( '#participants table tr.red' );

      // catch events from activities
      $( this ).on( 'recipient_added', function( event, participant, name, email, price ){
        recipients.push({
          id: participant,
          name: name,
          email: email
        });

        if( price > 0 ){
          debtors.push({
            id: participant,
            name: name,
            email: email
          });
        }

        $( form ).find( '#recipients select' ).trigger( 'change', [ $( form ).find( '#recipients select' ).val() ] );
      });

      // or if the activity is free
      $( this ).on( 'recipient_payed', function( event, participant, name, email ){
        debtors.remove( participant );
        $( form ).find( '#recipients select' ).trigger( 'change', [ $( form ).find( '#recipients select' ).val() ] );
      });

      // or if somebody set on not paid
      $( this ).on( 'recipient_unpayed', function( event, participant, name, email ){
        debtors.push({
          id: participant,
          name: name,
          email: email
        });

        $( form ).find( '#recipients select' ).trigger( 'change', [ $( form ).find( '#recipients select' ).val() ] );
      });

      $( this ).on( 'recipient_removed', function( event, participant, name, email ){
        recipients.remove( participant );
        debtors.remove( participant );

        $( form ).find( '#recipients select' ).trigger( 'change', [ $( form ).find( '#recipients select' ).val() ] );
      });


      // catch events from mail form
      $( this ).find( '#recipients select' ).on( 'change', function( event, selector ){
        if( selector == 'all' || $(this).val() == 'all' )
          $( form ).find( '#recipients input' ).val( $.fn.mail.format( recipients ));
        if( selector == 'debtors' || $(this).val() == 'debtors' )
          $( form ).find( '#recipients input' ).val( $.fn.mail.format( debtors ));
      });

      $( this ).on( 'submit', function( event ){
        event.preventDefault();

        if(!confirm( 'Weet je het zeker?' ))
          return;

        var list;
        if( $( form ).find( '#recipients select' ).val() == 'all' )
          list = recipients;
        else if( $( form ).find( '#recipients select' ).val() == 'debtors' )
          list = debtors;

        $.ajax({
          url: '/activities/' + $( form ).attr( 'data-id' ) + '/participants/mail',
          type: 'POST',
          data: {
            recipients: list,

            subject: $( form ).find( 'input#onderwerp' ).val(),
            html: $( form ).find( opts.message ).val()
            }
        }).done(function( data ){
          alert( 'mail is verstuurd' );
        }).fail(function( data ){
          alert( 'mail is niet verstuurd', 'error' );
        });
      });

    });
  };

  $.fn.mail.list = function( selector ){
    var list = [];

    $( selector ).each( function( id, row ){
      list.push({
        id: $( row ).attr( 'data-id' ),
        name: $( row ).find( 'a' ).html(),
        email: $( row ).attr( 'data-email' )
      });
    });

    return list;
  };

  $.fn.mail.format = function( array ){
    var string = ''

    $( array ).each( function( id, item ){
      if( item === undefined)
        return;

      string += item.name + ' <' + item.email + '>, '
    });

    return string;
  };

  $.fn.mail.defaults = {
    message: 'textarea#html'
  };

  Array.prototype.remove = function() {
    for (var i = 0; i < this.length; i++) {
      if( this[i].id == arguments[0] )
        return this.splice(i, 1);
    }
  };

}( jQuery ));
