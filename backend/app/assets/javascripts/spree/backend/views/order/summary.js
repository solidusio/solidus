Spree.Views.Order.Summary = Backbone.View.extend({
  initialize: function () {
    this.listenTo(this.model, "change", this.render);
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
    this.$('dd.order-shipment_state').html(this.renderState('shipment_states', this.model.get("shipment_state")))

    this.$('.order-payment_state').toggleClass("hidden", !this.model.get("completed_at"))
    this.$('dd.order-payment_state').html(this.renderState('payment_states', this.model.get("payment_state")))
  },

  renderState: function(translation_key, value) {
    var state_name = Spree.translations[translation_key][value] || value;
    return $('<span>')
      .addClass('state')
      .addClass(value)
      .text(state_name);
  }
});
