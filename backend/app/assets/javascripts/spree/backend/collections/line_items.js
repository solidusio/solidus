//= require spree/backend/models/line_item

Spree.Collections = (Spree.Collections || {})

Spree.Collections.LineItems = Backbone.Collection.extend({
  model: Spree.Models.LineItem,

  initialize: function(options) {
    options || (options = {});
    this.order = options.order;
  },

  url: function () {
    return this.order.url() + "/line_items";
  },
})
