//  Document load handler
//= require bootstrap-file-input

$(document).on( 'ready page:load turbolinks:load', function(){

  // Update poster field when uploading a poster
  $('form .input-group-append .file-input-wrapper input[type="file"]').on('change', function(){
    if( this.files && this.files[0] ){
      $('form .input-group-append .dropdown-toggle').removeClass('disabled');
      $('form input.remove_poster').val('false');
      $('form .input-group input#output').val(this.files[0].name);
    }
  });

  // Handler for removing the poster
  $('form .input-group-append a.remove').on('click', function( e ){
    e.preventDefault();

    $('form .input-group-append .dropdown-toggle').addClass('disabled');
    $('form .input-group input#output').val('');
    $('form input.remove_poster').val('true');

    $('form .file-input-wrapper input[type="file"]').val(null);
    $('form .thumb img').remove();
  });

  // Handler for uploading the poster (keep user waiting)
  $('form').on('submit', function(){
    $( this ).find('button[type="submit"].wait').addClass('disabled');
  });
});
