// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load turbolinks:load', function () {

  $('.education label a#copy-row').bind('click', function () {
    var row = $('div.education div.study:last').clone().insertAfter($('.education div.study:last'));

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
    var selector = $('.education .form-group.study > a.btn');

    if (typeof el !== "undefined" && el !== null)
      selector = $(el).find('a.btn');

    $(selector).bind("click", function () {
      var row = $(this).closest('.form-group.study');

      var destroy = $(row).find('input.destroy');

      if (destroy.val() == 'true') {
        $(row).find('input.form-control').removeAttr('disabled');
        $(row).find('select').removeAttr('disabled');

        $(destroy).val("false");
        $(this).html("<span class='fa fa-trash'></span>");

      } else {
        // don't remove newly created form
        if (!$(row).find('input.id').val())
          $(row).find('input[type="hidden"]').attr('disabled', 'disabled');

        $(row).find('input.form-control').attr('disabled', 'disabled');
        $(row).find('select').attr('disabled', 'disabled');

        $(destroy).val("true");
        $(this).html("<span class='fa fa-undo'></span>");
      }
    });
  }

  destroy(null);
});
