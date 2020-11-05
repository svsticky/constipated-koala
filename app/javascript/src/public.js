$(document).on("ready page:load turbolinks:load", function () {
  // on change recheck if still a student
  $(".studies .ui-select select").on("change", function () {
    if (
      $(".studies .ui-select select")
        .map(function () {
          return this.value;
        })
        .get()
        .includes("active")
    ) {
      $(".consent").hide();
      $('.consent input[type="checkbox"]').prop("checked", false);
      $("button.btn-success[type=submit]").removeAttr("disabled");
    } else {
      if (
        $('.consent input[type="checkbox"]')
          .map(function () {
            return $(this).prop("checked");
          })
          .get()
          .includes(true)
      ) {
        return;
      }

      $("button.btn-success[type=submit]").attr("disabled", true);
      $(".consent").show();
      $("html, body").animate({ scrollTop: $(".consent").offset().top }, 500);
    }
  });

  $('.consent input[type="checkbox"]').on("change", function () {
    if (
      $('.consent input[type="checkbox"]')
        .map(function () {
          return $(this).prop("checked");
        })
        .get()
        .includes(true)
    ) {
      $("button.btn-success[type=submit]").removeAttr("disabled");
    } else {
      if (
        $(".studies .ui-select select")
          .map(function () {
            return this.value;
          })
          .get()
          .includes("active")
      ) {
        return;
      }

      $("button.btn-success[type=submit]").attr("disabled", true);
    }
  });

  // hide consent if any study is active
  if (
    $(".studies .ui-select select")
      .map(function () {
        return this.value;
      })
      .get()
      .includes("active")
  ) {
    $(".consent").hide();
    $("button.btn-success[type=submit]").removeAttr("disabled");
  } else {
    $("button.btn-success[type=submit]").attr("disabled", true);
  }
});
