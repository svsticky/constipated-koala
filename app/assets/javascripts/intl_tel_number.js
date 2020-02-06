//= require intl-tel-input/build/js/intlTelInput
//= require intl-tel-input/build/js/utils

// international phone number input + validation

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

  // client side phone number validation, only check if input has anything in it
  function validate_phone_number(input, instance) {
    if (input.value.trim()) {
      if (instance.isValidNumber()) {
        input.classList.add('valid');
        input.classList.remove('invalid');
      }
      else {
        input.classList.remove('valid');
        input.classList.add('invalid');
      }
    }
  }

  // event listeners to revalidate the phone numbers
  if (phone_input != null) {
    phone_input.addEventListener('blur', function() {
      validate_phone_number(phone_input, iti_phone_input)
    });
  }

  if (emergency_phone_input != null) {
    emergency_phone_input.addEventListener('blur', function() {
      validate_phone_number(emergency_phone_input, iti_emergency_phone_input)
    });
  }

});
