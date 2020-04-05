// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on( 'ready page:load turbolinks:load', function(){
  // $('form.post-content').editor();

  let quill = new Quill('form.post-content #editor', {
    modules: {
      toolbar: [
        [{ header: [1, 2, 3, 4, false] }],
        ['bold', 'italic', 'underline', 'strike'],
        [{ 'list': 'ordered'}, { 'list': 'bullet' }],
        ['link', { 'color': [] }],
        ['clean']
      ]
    },
    theme: 'snow'
  });

  quill.editor.scroll.domNode.addEventListener('blur', () => {
    document.querySelectorAll('input#post-content')[0].value = quill.root.innerHTML
  })

  document.querySelectorAll('form.post-content')[0].addEventListener('submit', () => {
    document.querySelectorAll('input#post-content')[0].value = quill.root.innerHTML
  })
});
