//= require spree/backend/models
//= require spree/backend/orders/line_items
//= require spree/backend/orders/order_summary
//= require spree/backend/orders/order_details

Spree.Order || (Spree.Order = {})

Spree.Order.initCartPage = function(order_number) {
  var order = new Spree.Models.Order({number: order_number, line_items: [], shipments: []})
  var collection = order.get("line_items")

  new Spree.Order.OrderSummaryView({
    el: $('#order_tab_summary'),
    model: order
  });

  new Spree.CartLineItemTableView({
    el: $("table.line-items > tbody"),
    collection: collection
  });

  new Spree.CartAddLineItemButtonView({
    el: $('.js-add-line-item'),
    collection: collection
  });

  new Spree.Order.OrderDetailsTotalView({
    el: $('#order-total'),
    model: order
  });

  new Spree.Order.OrderDetailsAdjustmentsView({
    el: $('.js-order-line-item-adjustments'),
    model: order,
    collection: order.get("line_items")
  });

  new Spree.Order.OrderDetailsAdjustmentsView({
    el: $('.js-order-shipment-adjustments'),
    model: order,
    collection: order.get("shipments")
  });

  new Spree.Order.OrderDetailsAdjustmentsView({
    el: $('.js-order-adjustments'),
    model: order
  });

  order.fetch({
    success: function() {
      /* If there are no existing items, start creating one immediately */
      if(!collection.length) {
        collection.push({});
      }
    }
  })
}

$(function() {
  if ($(".js-order-cart-page").length) {
    Spree.Order.initCartPage($(".js-order-cart-page").data("order-number"));
  }
});
