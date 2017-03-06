//= require spree/backend/routes

Spree.Models.LineItem = Backbone.Model.extend({
  initialize: function(options) {
    this.order = this.collection.parent;
  }
})
