(function( $ ){
  
  $.fn.editor = function( options ){
    var opts = $.extend({}, $.fn.editor.defaults, options);
    
    // div containing styled wysiwyg
    var textarea = $( this ).find( opts.textarea );
    var form = $( this );
    
    return this.each(function(){
      
      $( this ).on( 'submit', function( event ){
        $( form ).find( opts.htmlarea ).val( $( form ).find( opts.textarea ).html() );
      });
      
      // toggle buttons pending on location of the carrot
      $( textarea ).on( 'click keydown blur', function( event ){

        $( form ).find( '.ta-toolbar > .btn-group > button:not(.dropdown-toggle):not(.disabled)' ).each( function( iterator, button ){
          $.fn.editor.active( button );
        });
        
      });
      
      
      // connect buttons to the functions
      $( this ).find( '.ta-toolbar > .btn-group > button:not(.dropdown-toggle):not(.disabled)' ).on( 'click', function( event ){
        $( textarea ).trigger( event.currentTarget.name );
        
        if( event.currentTarget.name != 'html' && event.currentTarget.name != 'erase' )
          $( event.currentTarget ).toggleClass( 'active' );
          
        $( textarea ).focus();
        event.preventDefault();
      });
      
      $( this ).find( '.ta-toolbar > .btn-group > ul.dropdown-menu > li > a' ).on( 'mousedown', function( event ){
        $( textarea ).trigger( event.currentTarget.className, [ event.currentTarget.name, window.getSelection() ] );
        
        $( textarea ).focus();
        event.preventDefault();
      });
      
      
      // functions for the buttons
      $( textarea ).on( 'bold', function( event ){ //TODO somehting with selection
        document.execCommand( 'bold', false, true );
      });
      
      $( textarea ).on( 'italic', function( event ){
        document.execCommand( 'italic', false, true );
      });
      
      $( textarea ).on( 'underline', function( event ){
        document.execCommand( 'underline', false, true );
      });
      
      $( textarea ).on( 'strikethrough', function( event ){
        document.execCommand( 'strikethrough', false, true );
      });
      
      
      $( textarea ).on( 'ol', function( event ){
        document.execCommand( 'insertOrderedList', false, true );
      });      
      
      $( textarea ).on( 'ul', function( event ){
        document.execCommand( 'insertUnorderedList', false, true );
      }); 
      

      $( textarea ).on( 'left', function( event ){
        $( form ).find( '.ta-toolbar > .btn-group > button[name="center"]' ).removeClass( 'active' );
        $( form ).find( '.ta-toolbar > .btn-group > button[name="right"]' ).removeClass( 'active' );
        
        document.execCommand( 'justifyLeft', false, true );
      });
      
      $( textarea ).on( 'center', function( event ){
        $( form ).find( '.ta-toolbar > .btn-group > button[name="left"]' ).removeClass( 'active' );
        $( form ).find( '.ta-toolbar > .btn-group > button[name="right"]' ).removeClass( 'active' );
        
        document.execCommand( 'justifyCenter', false, true );
      });      
      
      $( textarea ).on( 'right', function( event ){
        $( form ).find( '.ta-toolbar > .btn-group > button[name="left"]' ).removeClass( 'active' );
        $( form ).find( '.ta-toolbar > .btn-group > button[name="center"]' ).removeClass( 'active' );
        
        document.execCommand( 'justifyRight', false, true );
      }); 
      
      $( textarea ).on( 'erase', function( event ){
        document.execCommand( 'removeFormat', false, true );
      }); 
      
      
      $( textarea ).on( 'html', function( event ){
        // toggle html view
        if( $( form ).hasClass('html') )
          $( form ).find( opts.textarea ).html( $( form ).find( opts.htmlarea ).val() );
        else
          $( form ).find( opts.htmlarea ).val( $( form ).find( opts.textarea ).html() );
        
        $( form ).toggleClass( 'html' );
        $( form ).find( '.ta-toolbar > .btn-group > button[name="html"]' ).toggleClass('active');
        $( form ).find( '.ta-toolbar > .btn-group > button[name!="html"]' ).toggleClass('disabled').removeClass('active');
      });
      
      
      // function for the dropdowns
      $( textarea ).on( 'font-family', function( event, font, selection ){ //TODO somehting with selection        
        document.execCommand( 'fontName', false, $.fn.editor.fonts[font] );
      });
      
      $( textarea ).on( 'font-size', function( event, size, selection ){
        if( size == 'small' )
          document.execCommand( 'fontSize', false, 1 );
        else if( size == 'large' )
          document.execCommand( 'fontSize', false, 4 );
        else //font weghalen
          document.execCommand( 'fontSize', false, 3 );
      });
    });
    
    
  };
  
  $.fn.editor.defaults = {
    htmlarea: 'textarea#html',
    textarea: '#textarea'
  };
  
  $.fn.editor.functions = {
    'bold':           'bold',
    'italic':         'italic',
    'underline':      'underline',
    'strikethrough':  'strikethrough',
    
    'ol':             'insertOrderedList',
    'ul':             'insertUnorderedList',
    
    'left':           'justifyLeft',
    'center':         'justifyCenter',
    'right':          'justifyRight'
  }
  
  $.fn.editor.fonts = {
    'arial':          'arial, sans-serif',
    'georgia':        'georgia',
    'verdana':        'verdana',
    'tahoma':         'tahome',
    'comic sans':     'comic sans ms'
  }
  
  $.fn.editor.active = function( button ){
   
    if( $( button ).attr( 'name' ) == 'html' )
      return
   
    if( document.queryCommandValue( $.fn.editor.functions[$( button ).attr( 'name' )] ) === 'true' )
      $( button ).addClass( 'active' )
    else
      $( button ).removeClass( 'active' )
  }
  
}( jQuery ));