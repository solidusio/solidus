Spree.Order || (Spree.Order = {})

Spree.Order.initCartPage = function(order_number) {
  var order = new Spree.Models.Order.fetch(order_number)
  var collection = order.get("line_items")

  new Spree.Views.Order.Summary({
    el: $('#order_tab_summary'),
    model: order
  });

  new Spree.Views.Cart.LineItemTable({
    el: $("table.line-items > tbody"),
    collection: collection
  });

  new Spree.Views.Cart.AddLineItemButton({
    el: $('.js-add-line-item'),
    collection: collection
  });

  new Spree.Views.Cart.EmptyCartButton({
    el: $('.js-empty-cart'),
    collection: collection,
    model: order
  });

  new Spree.Views.Order.DetailsTotal({
    el: $('#order-total'),
    model: order
  });

  new Spree.Views.Order.DetailsAdjustments({
    el: $('.js-order-line-item-adjustments'),
    model: order,
    collection: order.get("line_items")
  });

  new Spree.Views.Order.DetailsAdjustments({
    el: $('.js-order-shipment-adjustments'),
    model: order,
    collection: order.get("shipments")
  });

  new Spree.Views.Order.DetailsAdjustments({
    el: $('.js-order-adjustments'),
    model: order
  });

  order.on("sync", function() {
    if(!collection.length) {
      collection.push({});
    }
  })
}

Spree.ready(function() {
  if ($(".js-order-cart-page").length) {
    Spree.Order.initCartPage($(".js-order-cart-page").data("order-number"));
  }
});
