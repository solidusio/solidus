$(function() {
  if($(".js-customer-details").length) {
    new Spree.Views.Order.CustomerDetails({
      el: $(".js-customer-details")
    });
  }
});
