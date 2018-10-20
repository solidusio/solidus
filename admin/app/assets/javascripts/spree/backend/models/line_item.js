//= require spree/backend/routes

Spree.Models.LineItem = Backbone.Model.extend({
  defaults: {
    quantity: 1
  },

  initialize: function(options) {
    this.order = this.collection.parent;
  }
})
