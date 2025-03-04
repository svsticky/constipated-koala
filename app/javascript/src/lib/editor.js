/**
 * @file editor.js
 * A wysiwyg editor using jQuery, bootstrap, and font-awesome icons.
 *
 * @author Martijn Casteel
 */
import jQuery from "jquery";
import Quill from "quill";

(function ($) {
  $.fn.editor = function (options) {
    if ($(this).length === 0) return;

    let modules = $.extend({}, $.fn.defaults, options);
    let editors = $(this).find("#editor, .quill-editor");

    editors.each(function () {
      // form-group containing hidden input to copy inner html to
      let input = $(this).parent().find("input:hidden");

      let quill = new Quill(this, {
        modules: modules,
        theme: "snow",
      });

      let store = function () {
        $(input).first().val(quill.root.innerHTML);
      };

      $(quill.editor.scroll.domNode).on("blur", store);
      $(this).closest("form").on("submit", store);
    });
  };

  $.fn.defaults = {
    toolbar: [
      ["link", "blockquote", "code-block"],
      ["bold", "italic", "underline", "strike"],
      [{ script: "sub" }, { script: "super" }],
      [{ list: "ordered" }, { list: "bullet" }],
      [{ indent: "-1" }, { indent: "+1" }],
      [
        { align: null },
        { align: "center" },
        { align: "right" },
        { align: "justify" },
      ],
      ["clean"],
    ],
  };
})(jQuery);
