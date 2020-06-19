// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

//=require intl_tel_number

$(document).on('ready page:load turbolinks:load', function () {

  setup_intl_tel_input();

  $('.education label a.close').bind('click', function () {
    var row = $('.education .copyable:last').clone().insertAfter($('.education .copyable:last'));

    //member[educations_attributes][39][name_id]
    var name = $(row).find('select').attr('name');
    var id = name.match(/\[(-?\d*\d+)]/)[1];

    if (+id < 0)
      id = +id - 1;
    else
      id = -1;

    //replace all inputs and select name and id?
    $(row).find('input').each(function () {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)]/, '[' + id + ']'));
    });

    $(row).find('select').each(function () {
      $(this).val('').attr("name", $(this).attr("name").replace(/\[(-?\d*\d+)]/, '[' + id + ']'));
    });

    destroy(row);
  });

  function destroy(el) {
    var selector = $('.education .form-group a.btn.destroy');

    if (typeof el !== "undefined" && el !== null)
      selector = $(el).find('a.btn.destroy');

    $(selector).bind("click", function () {
      var row = $(this).closest('.form-group');

      var destroy = $(row).find('input.destroy');

      if (destroy.val() == 'true') {
        $(row).find('input').removeAttr('disabled');
        $(row).find('select').removeAttr('disabled').removeAttr('style').css('width', '100%');

        $(destroy).val("false");
        $(this).html("<span class='fa fa-trash'></span>");
        $(row).find('input.form-control').attr('disabled', 'disabled');

      } else {
        if (!$(row).find('input.id').val())
          $(row).find('input[type="hidden"]').attr('disabled', 'disabled');
        $(row).find('input.form-control').attr('disabled', 'disabled');
        $(row)
          .find('select')
          .attr('disabled', 'disabled')
          .css('background-color', 'rgb(238, 238, 238)')
          .css('color', 'rgb(118, 118, 118)')
          .css('border-color', 'rgb(203, 213, 221)');

        $(destroy).val("true");
        $(this).html("<span class='fa fa-undo'></span>");
      }
    });
  }

  // after member is selected, set an amount
  var creditInputGroup = $('#credit.input-group');
  var inputAmount = creditInputGroup.find('input#amount');
  var paymentMethodInput = creditInputGroup.find('select#payment_method');
  creditInputGroup.find('#upgrade-btn').on('click', function () {
    var token = encodeURIComponent($(this).closest('.page').attr('data-authenticity-token'));

    if (!inputAmount.val()) {
      toastr.error(I18n.t('admin.members.top_up_error'));
      return;
    }

    if (inputAmount.prop('disabled'))
      return;

    var price = $(inputAmount).val();

    // Make it a bit more pretty
    if (!isNaN(price))
      $(this).val(parseFloat(price).toFixed(2));

    inputAmount.prop('disabled', true);

    $.ajax({
      url: '/apps/transactions',
      type: 'PATCH',
      data: {
        member_id: creditInputGroup.attr('data-member-id'),
        amount: price,
        payment_method: paymentMethodInput.val(),
        authenticity_token: token
      }
    }).done(function (data) {
      inputAmount.prop('disabled', false);
      toastr.success(I18n.t('admin.members.top_up'));

      //toevoegen aan de lijst
      $('#transactions').trigger('transaction_added', data); //TODO

      //remove from input and select
      paymentMethodInput.val('');
      inputAmount.val('');

    }).fail(function (data) {
      inputAmount.prop('disabled', false);

      if (!data.responseJSON) {
        toastr.error(data.statusText, data.status);
        return;
      }

      let errors = data.responseJSON.errors;
      let text = "";
      for (let attribute in errors) {
        for (let error of errors[attribute])
          text += error + ', ';

        // remove last colon and space
        text = text.slice(0, -2);
        text += '<br/>';
      }
      // remove last line break
      text = text.slice(0, -5);

      toastr.error(text);
    });
  });

  destroy(null);
});
