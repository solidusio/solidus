Spree.Views.Order.ShippingMethod = Backbone.View.extend({
  tagName: 'tr',
  className: 'edit-shipping-method',

  events: {
    "click .js-edit":   "onEdit",
    "click .js-save":   "onSave",
    "submit form":      "onSave",
    "click .js-cancel": "onCancel"
  },

  initialize: function(options) {
    this.shippingMethodId = this.model.get('selected_shipping_rate').get('shipping_method_id');
    this.shippingRates = new Backbone.Collection();
    this.render();
  },

  onEdit: function(event) {
    this.editing = true;
    this.shippingRates = this.model.estimatedRates();
    this.listenTo(this.shippingRates, "sync", this.render);
    this.render();
  },

  onSave: function(event) {
    this.editing = false;
    this.shippingMethodId = this.$('select').val();
    this.shippingRates = new Backbone.Collection();
    this.model.selectShippingMethodId(this.shippingMethodId, {
      success: function() {
        window.location.reload();
      }
    });
    this.render();

    return false;
  },

  onCancel: function(event) {
    this.editing = false;
    this.shippingRates = new Backbone.Collection();
    this.render();
  },

  render: function() {
    var html = HandlebarsTemplates['orders/shipping_method']({
      editing: this.editing,
      order: this.model.collection.parent.toJSON(),
      shipment: this.model.toJSON(),
      selected_shipping_rate: this.model.get("selected_shipping_rate").toJSON(),
      shipping_rates: this.shippingRates.toJSON()
    });

    this.$el.html(html);
    this.$('select').val(this.shippingMethodId);
  }
})
