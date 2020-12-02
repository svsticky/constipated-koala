import I18n from '../i18n.js.erb'

import jQuery from "jquery";
import toastr from "toastr";

/**
 * @file mail.js
 * A mail pane using the wysiwyg editor for composing mails and calling a
 * function to send it.
 *
 * @author Martijn Casteel
 */

(function( $ ){

  $.fn.mail = function( options ){
    var opts = $.extend({}, $.fn.mail.defaults, options);
    var form = $( this );

    var recipients, debtors, attendees, reservists;

    return this.each(function(){

      // activate wysiwyg editor
      $( this ).editor({ htmlarea: opts.message });

      // fill the lists of recipients and debtors
      recipients = $.fn.mail.list( '#participants table tr[data-reservist]' );
      attendees = $.fn.mail.list( '#participants table tr[data-reservist="false"]' );
      reservists = $.fn.mail.list( '#participants table tr[data-reservist="true"]' );
      debtors = $.fn.mail.list( '#participants table tr.in-debt' );

      // catch events from activities
      $( this ).on( 'recipient_added', function( event, participant, name, email, price ){
        var data = {id: participant, name: name, email: email};

        recipients.push(data);
        attendees.push(data);
        reservists.remove(participant);

        if( price > 0 ){
          debtors.push(data);
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
        attendees.remove( participant );
        debtors.remove( participant );
        reservists.remove( participant );

        $( form ).find( '#recipients select' ).trigger( 'change', [ $( form ).find( '#recipients select' ).val() ] );
      });


      // catch events from mail form
      $( this ).find( '#recipients select' ).on( 'change', function( event, selector ){
        if( selector == 'all' || $(this).val() == 'all' )
          $( form ).find( '#recipients input' ).val( $.fn.mail.format( recipients ));
        if( selector == 'debtors' || $(this).val() == 'debtors' )
          $( form ).find( '#recipients input' ).val( $.fn.mail.format( debtors ));
        if( selector == 'attendees' || $(this).val() == 'attendees' )
          $( form ).find( '#recipients input' ).val( $.fn.mail.format( attendees ));
        if( selector == 'reservists' || $(this).val() == 'reservists' )
          $( form ).find( '#recipients input' ).val( $.fn.mail.format( reservists ));
      });

      $( this ).on( 'submit', function( event ){
        event.preventDefault();

        if(!confirm( I18n.t('mailings.confirm') ))
          return;

        var list;
        if( $( form ).find( '#recipients select' ).val() == 'all' )
          list = recipients;
        else if( $( form ).find( '#recipients select' ).val() == 'debtors' )
          list = debtors;
        else if( $( form ).find( '#recipients select' ).val() == 'attendees' )
          list = attendees;
        else if( $( form ).find( '#recipients select' ).val() == 'reservists' )
            list = reservists;

        $.ajax({
          url: '/activities/' + $( form ).attr( 'data-id' ) + '/participants/mail',
          type: 'POST',
          data: {
            recipients: list,

            subject: $( form ).find( 'input#onderwerp' ).val(),
            html: $( form ).find( opts.message ).val()
            }
        }).done(function( data ){
          toastr.success(I18n.t('mailings.sent.true'));
        }).fail(function( data ){
          toastr.error(I18n.t('mailings.sent.false'));
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
