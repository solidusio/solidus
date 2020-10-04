//= require jquery.payment
//= require_self
//= require spree/frontend/checkout/address
//= require spree/frontend/checkout/payment
//= require spree/frontend/checkout/coupon-code

Spree.disableSaveOnClick = function() {
  $("form.edit_order").submit(function() {
    $(this)
      .find(":submit, :image")
      .attr("disabled", true)
      .removeClass("primary")
      .addClass("disabled");
  });
};

Spree.ready(function($) {
  var termsCheckbox = $("#accept_terms_and_conditions");
  termsCheckbox.change(function() {
    var submitBtn = $(this.closest("form")).find(":submit");
    submitBtn.prop("disabled", !this.checked);
    submitBtn.toggleClass("disabled", !this.checked);
  });
});
