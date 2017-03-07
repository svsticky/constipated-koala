$(document).on('ready page:load', function(){

  //Initialise clipboard-rails
  var clip = new Clipboard('.btn-clipboard', {
    text: function(trigger) {
      return getWhatsappText(trigger.getAttribute('data-texturl'));
    }
  });
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
