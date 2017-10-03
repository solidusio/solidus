Spree.Views.Order.ShipmentTracking = Backbone.View.extend({
  tagName: 'tr',
  className: 'edit-tracking',

  events: {
    "click .js-edit":   "onEdit",
    "click .js-save":   "onSave",
    "submit form":      "onSave",
    "click .js-cancel": "onCancel",
  },

  initialize: function(options) {
    this.render();
  },

  onEdit: function(event) {
    this.editing = true;
    this.render();
  },

  onSave: function(event) {
    this.editing = false;
    this.model.save({
      tracking: this.$('input[type="text"]').val()
    }, {
      patch: true
    });
    this.render();

    return false;
  },

  onCancel: function(event) {
    this.editing = false;
    this.render();
  },

  render: function() {
    var html = HandlebarsTemplates['orders/shipment_tracking']({
      editing: this.editing,
      tracking: this.model.get("tracking"),
    });

    this.$el.html(html);
  }
});
