//= require jquery.payment
//= require_self
//= require spree/frontend/checkout/address
//= require spree/frontend/checkout/payment
//= require spree/frontend/checkout/coupon-code
Spree.disableSaveOnClick = function() {
  return ($('form.edit_order')).submit(function() {
    return ($(this)).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass('disabled');
  });
};

Spree.ready(function($) {
  var termsCheckbox;
  termsCheckbox = $('#accept_terms_and_conditions');
  return termsCheckbox.change(function() {
    var submitBtn;
    submitBtn = $(this.closest('form')).find(':submit');
    submitBtn.prop('disabled', !this.checked);
    return submitBtn.toggleClass('disabled', !this.checked);
  });
});
