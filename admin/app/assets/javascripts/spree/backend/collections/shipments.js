//= require spree/backend/routes
//= require spree/backend/models/shipment

Spree.Collections.Shipments = Backbone.Collection.extend({
  model: Spree.Models.Shipment
})
