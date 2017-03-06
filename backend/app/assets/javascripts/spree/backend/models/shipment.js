//= require spree/backend/routes

Spree.Models.Shipment = Backbone.Model.extend({
  urlRoot: Spree.routes.shipments_api,
  idAttribute: "number",
  paramRoot: "shipment",

  initialize: function(options) {
    this.order = this.collection.parent;
  }
})
