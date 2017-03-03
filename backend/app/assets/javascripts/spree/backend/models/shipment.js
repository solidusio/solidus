//= require spree/backend/routes

Spree.Models.Shipment = Backbone.Model.extend({
  urlRoot: Spree.routes.shipments_api,
  idAttribute: "number",
})
