Spree.ready(function() {
  if($(".js-customer-details").length) {
    var order = new Spree.Models.Order({
      bill_address: {},
      ship_address: {}
    });
    new Spree.Views.Order.CustomerDetails({
      el: $(".js-customer-details"),
      model: order
    });
  }
});
