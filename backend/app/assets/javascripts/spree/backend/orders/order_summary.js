Spree.Order || (Spree.Order = {});

Spree.Order.OrderModel = Backbone.Model.extend({
});

Spree.Order.OrderSummaryView = Backbone.View.extend({
  initialize: function () {
    this.render()
  },

  render: function () {
    this.$('dd.order-state').html(this.renderState('order_state', this.model.get("state")))

    this.$("#item_total").text(this.model.get("display_item_total"));
    this.$("#order_total").text(this.model.get("display_total"));

    this.$('.order-shipment_total').toggleClass("hidden", !Number(this.model.get("ship_total")))
    this.$('dd.order-shipment_total').text(this.model.get("display_ship_total"))

    this.$('.order-included_tax_total').toggleClass("hidden", !Number(this.model.get("included_tax_total")))
    this.$('dd.order-included_tax_total').text(this.model.get("display_included_tax_total"))

    this.$('.order-additional_tax_total').toggleClass("hidden", !Number(this.model.get("additional_tax_total")))
    this.$('dd.order-additional_tax_total').text(this.model.get("display_additional_tax_total"))

    this.$('.order-shipment_state').toggleClass("hidden", !this.model.get("completed_at"))
    this.$('dd.order-shipment_state').html(this.renderState('shipment_state', this.model.get("shipment_state")))

    this.$('.order-payment_state').toggleClass("hidden", !this.model.get("completed_at"))
    this.$('dd.order-payment_state').html(this.renderState('payment_state', this.model.get("payment_state")))
  },

  renderState: function(translation_key, value) {
    var state_name = Spree.translations[translation_key][value] || value;
    return $('<span>')
      .addClass('state')
      .addClass(value)
      .text(state_name);
  }
});

$(function(){
  var url = Spree.routes.orders_api + "/" + order_number
  $('#order_tab_summary').each(function(){
    var el = this;
    Spree.ajax({url: url}).done(function(result) {
      var order = new Spree.Order.OrderModel(result);
      new Spree.Order.OrderSummaryView({
        el: el,
        model: order
      });
    });
  });
})
