/**
 * @file mail.js
 * A mail pane using the wysiwyg editor for composing mails and calling a
 * function to send it.
 *
 * @author Martijn Casteel
 */

(function($){

  $.fn.mail = function( options ){
    var opts = $.extend({}, $.fn.mail.defaults, options);
    var form = $( this );

    var recipients, debtors, attendees, reservists;

    
  var editor = function(form, options) {
    var opts = $.extend({}, $.fn.editor.defaults, options);

    // div containing styled wysiwyg
    var textarea = $(form).find(opts.textarea);

    return $(form).each(function() {
      $(this).on("submit", function(event) {
        if (!$(form).hasClass("html"))
          $(form)
            .find(opts.htmlarea)
            .val(
              $(form)
                .find(opts.textarea)
                .html()
            );
      });

      // toggle buttons pending on location of the carrot
      $(textarea).on("click keydown keyup blur", function(event) {
        $(form)
          .find(
            ".ta-toolbar > .btn-group > button:not(.dropdown-toggle):not(.disabled)"
          )
          .each(function(iterator, button) {
            $.fn.editor.active(button);
          });
      });

      // connect buttons to the functions
      $(this)
        .find(
          ".ta-toolbar > .btn-group > button:not(.dropdown-toggle):not(.disabled)"
        )
        .off("click");
      $(this)
        .find(
          ".ta-toolbar > .btn-group > button:not(.dropdown-toggle):not(.disabled)"
        )
        .on("click", function(event) {
          $(textarea).trigger(event.currentTarget.name);

          if (
            event.currentTarget.name != "html" &&
            event.currentTarget.name != "erase"
          )
            $(event.currentTarget).toggleClass("active");

          $(textarea).focus();
          event.preventDefault();
        });

      $(this)
        .find(".ta-toolbar > .btn-group > ul.dropdown-menu > li > a")
        .on("mousedown", function(event) {
          $(textarea).trigger(event.currentTarget.className, [
            event.currentTarget.name,
            window.getSelection()
          ]);

          $(textarea).focus();
          event.preventDefault();
        });

      // functions for the buttons
      $(textarea).on("bold", function(event) {
        //TODO somehting with selection
        document.execCommand("bold", false, true);
      });

      $(textarea).on("italic", function(event) {
        document.execCommand("italic", false, true);
      });

      $(textarea).on("underline", function(event) {
        document.execCommand("underline", false, true);
      });

      $(textarea).on("strikethrough", function(event) {
        document.execCommand("strikethrough", false, true);
      });

      $(textarea).on("ol", function(event) {
        document.execCommand("insertOrderedList", false, true);
      });

      $(textarea).on("ul", function(event) {
        document.execCommand("insertUnorderedList", false, true);
      });

      $(textarea).on("left", function(event) {
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="center"]')
          .removeClass("active");
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="right"]')
          .removeClass("active");

        document.execCommand("justifyLeft", false, true);
      });

      $(textarea).on("center", function(event) {
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="left"]')
          .removeClass("active");
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="right"]')
          .removeClass("active");

        document.execCommand("justifyCenter", false, true);
      });

      $(textarea).on("right", function(event) {
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="left"]')
          .removeClass("active");
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="center"]')
          .removeClass("active");

        document.execCommand("justifyRight", false, true);
      });

      $(textarea).on("erase", function(event) {
        document.execCommand("removeFormat", false, true);
      });

      $(textarea).on("html", function(event) {
        // toggle html view
        if ($(form).hasClass("html"))
          $(form)
            .find(opts.textarea)
            .html(
              $(form)
                .find(opts.htmlarea)
                .val()
            );
        else
          $(form)
            .find(opts.htmlarea)
            .val(
              $(form)
                .find(opts.textarea)
                .html()
            );

        $(form).toggleClass("html");
        $(form)
          .find('.ta-toolbar > .btn-group > button[name="html"]')
          .toggleClass("active");
        $(form)
          .find('.ta-toolbar > .btn-group > button[name!="html"]')
          .toggleClass("disabled")
          .removeClass("active");
      });

      // function for the dropdowns
      $(textarea).on("font-family", function(event, font, selection) {
        //TODO somehting with selection
        document.execCommand("fontName", false, $.fn.editor.fonts[font]);
      });

      $(textarea).on("font-size", function(event, size, selection) {
        if (size == "small") document.execCommand("fontSize", false, 1);
        else if (size == "large") document.execCommand("fontSize", false, 4);
        //font weghalen
        else document.execCommand("fontSize", false, 3);
      });
    });
  }

    return this.each(function(){

      // activate wysiwyg editor
      editor(this, { htmlarea: opts.message });
      
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

        if(!confirm( 'Weet je het zeker?' ))
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
          toastr.success('Mail is verstuurd');
        }).fail(function( data ){
          toastr.error('Mail is niet verstuurd');
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

  $.fn.editor.defaults = {
    htmlarea: "textarea#html",
    textarea: "#textarea"
  };

  $.fn.editor.functions = {
    bold: "bold",
    italic: "italic",
    underline: "underline",
    strikethrough: "strikethrough",

    ol: "insertOrderedList",
    ul: "insertUnorderedList",

    left: "justifyLeft",
    center: "justifyCenter",
    right: "justifyRight"
  };

  $.fn.editor.fonts = {
    arial: "arial, sans-serif",
    georgia: "georgia",
    verdana: "verdana",
    tahoma: "tahome",
    "comic sans": "comic sans ms"
  };

  $.fn.editor.active = function(button) {
    if ($(button).attr("name") == "html") return;

    if (
      document.queryCommandValue(
        $.fn.editor.functions[$(button).attr("name")]
      ) === "true"
    )
      $(button).addClass("active");
    else $(button).removeClass("active");
  };

}( jQuery ));