/**
 * @file editor.js
 * A wysiwyg editor using jQuery, bootstrap, and font-awesome icons.
 *
 * @author Martijn Casteel
 */
import jQuery from "jquery";

(function($) {
  $.fn.editor = function(options) {
    if( $( this ).length == 0 )
      return

    var modules = $.extend({}, $.fn.defaults, options);

    // form-group containing hidden input to copy inner html to
    let input = $(this).find('input:hidden');
    let editor = $(this).find('#editor');

    if( $( editor ).length == 0 )
      return

    let quill = new Quill($(editor)[0], {
      modules: modules,
      theme: 'snow'
    });

    let store = function() {
      $(input).first().val(quill.root.innerHTML)
    }
  
    $(quill.editor.scroll.domNode).on('blur', store)
    $(this).closest('form').on('submit', store);
  }  

  $.fn.defaults = {
    toolbar: [
      [{ header: [1, 2, 3, 4, false] }],
      ['bold', 'italic', 'underline', 'strike'],
      ['clean']
    ]
  };
})(jQuery);
