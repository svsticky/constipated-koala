//= require intl-tel-input/build/js/intlTelInput
//= require intl-tel-input/build/js/utils

// phone number validation

$(document).on('ready page:load turbolinks:load', function(){
  var phone_input = document.querySelector('#member_phone_number');
  var emergency_phone_input = document.querySelector('#member_emergency_phone_number');

  if (phone_input != null && emergency_phone_input != null) {
    var iti_phone_input = window.intlTelInput(phone_input, {
      preferredCountries: ['nl'],
      separateDialCode: true,
      hiddenInput: 'phone_number',
      utilsScript: 'utils.js'
    });

    var iti_emergency_phone_input = window.intlTelInput(emergency_phone_input, {
      preferredCountries: ['nl'],
      separateDialCode: true,
      hiddenInput: 'emergency_phone_number',
      utilsScript: 'utils.js'
    });
  }
});
