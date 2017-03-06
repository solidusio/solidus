//= require spree/backend/models/line_item

Spree.Collections.LineItems = Backbone.Collection.extend({
  model: Spree.Models.LineItem,

  url: function () {
    return this.parent.url() + "/line_items";
  }
})
