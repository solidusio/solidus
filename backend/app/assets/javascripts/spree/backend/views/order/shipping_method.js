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
    this.shippingRateId = this.model.get('selected_shipping_rate').get('id')
    this.render();
  },

  onEdit: function(event) {
    this.editing = true;
    this.render();
  },

  onSave: function(event) {
    this.editing = false;
    this.model.save({
      selected_shipping_rate_id: this.$('select').val()
    }, {
      patch: true,
      success: function() {
        // FIXME: should update page without reloading
        window.location.reload();
      }
    });

    return false;
  },

  onCancel: function(event) {
    this.editing = false;
    this.render();
  },

  render: function() {
    var html = HandlebarsTemplates['orders/shipping_method']({
      editing: this.editing,
      order: this.model.collection.parent.toJSON(),
      shipment: this.model.toJSON(),
      selected_shipping_rate: this.model.get("selected_shipping_rate").toJSON(),
      shipping_rates: this.model.get("shipping_rates").toJSON()
    });

    this.$el.html(html);
    this.$('select').val(this.shippingRateId);
  }
})
