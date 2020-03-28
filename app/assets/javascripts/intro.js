// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery/dist/jquery
//= require turbolinks/dist/turbolinks
//= require bootstrap/dist/js/bootstrap
//= require jquery.validate

$(document).on('ready page:load turbolinks:load', function () {
  var disabledStudyOptions = null;
  var studyBlockers = {
    1: 3,
    3: 1
  };

  $("#menu-close").click(function (e) {
    e.preventDefault();
    $("#sidebar-wrapper").toggleClass("active");
  });

  $('.alert .close').on('click', function () {
    $(this).closest('.alert').remove();
  });

  $("a[href*='#']").click(function () {
    if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//,
        '') || location.hostname == this.hostname) {

      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
      if (target.length) {
        $('html,body').animate({
          scrollTop: target.offset().top
        }, 1000);
        return false;
      }
    }
  });

  jQuery.validator.addMethod("valid_student_id", function (value, element) {
    if (/\F\d{6}/.test(value)) {
      return true;
    }

    var numbers = value.split("").reverse();

    var sum = 0;
    for (index = 0; index < numbers.length; ++index) {
      sum += numbers[index] * (index + 1);
    }

    return sum % 11 === 0;
  }, "Studentnummer is niet geldig");

  jQuery.validator.addMethod("required_if_minor", function(value, element) {
    // get max birth date to be 18 years old, ignoring time
    var maxDate = new Date()
    maxDate.setUTCHours(0, 0, 0, 0)
    maxDate.setFullYear(maxDate.getFullYear() - 18)

    var birthDate = new Date($("#member_birth_date").val())

    // field is valid if member is 18 years or if it's not empty
    return (birthDate < maxDate || value)
  }, "Telefoonnummer voor calamiteiten is verplicht onder 18 jaar");

  $('form').validate({
    rules: {
      'member[first_name]': 'required',
      'member[last_name]': 'required',
      'member[birth_date]': 'required',
      'member[address]': 'required',
      'member[house_number]': 'required',
      'member[postal_code]': 'required',
      'member[city]': 'required',
      'member[phone_number]': 'required',
      'member[emergency_phone_number]': {
        required_if_minor: true
      },
      'member[email]': {
        required: true,
        email: true
      },
      'member[student_id]': {
        required: true,
        valid_student_id: true
      },
      'bank': {
        required: function () {
          return $('.ui-select select#method').val() == 'IDEAL';
        }
      }
    },
    errorClass: 'invalid',
    errorPlacement: function (error, element) {
    }
  });

  $('select#method').on("change", function () {
    if ($(this).val() == 'Cash/PIN') {
      $('select#bank')
        .attr('disabled', 'disabled')
        .css('background-color', 'rgb(238, 238, 238)')
        .css('color', 'rgb(118, 118, 118)')
        .css('border-color', 'rgb(203, 213, 221)');
      $('label#bank').css('color', 'rgb(222, 222, 222)');
    } else {
      $('select#bank').removeAttr('disabled').removeAttr('style');
      $('label#bank').removeAttr('style');
    }
  });

  $('.studies select').on('change', function () {
    var selected = $(this).find('option:selected');

    if (selected.data('masters')) {
      $('.activities').hide();
    } else {
      $('.activities').show();
    }

    if(disabledStudyOptions !== null){
      disabledStudyOptions.prop('disabled', false);
      disabledStudyOptions = null;
    }

    var blockedId = studyBlockers[selected.val()];
    if(typeof blockedId !== 'undefined'){
      disabledStudyOptions = $(this).closest('.studies > *').nextAll().find('option[value=' + blockedId + ']');
      disabledStudyOptions.prop('disabled', true);
    }
  });

  setTimeout(function () {
    $('.alert.alert-success').hide();
  }, 3000);

  var jumboHeight = $('.header').outerHeight();

  $(window).scroll(function (e) {
    var scrolled = $(window).scrollTop();
    $('.header-bg').css('height', (jumboHeight - scrolled) + 'px');
    $('.header-bg').css('height', (jumboHeight - scrolled) + 'px');
  });
});
