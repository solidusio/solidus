Spree.Models.Shipment = Backbone.Model.extend({
  idAttribute: "number",
  paramRoot: "shipment",
  urlRoot: Spree.routes.shipments_api,

  relations: {
    "selected_shipping_rate": Backbone.Model,
    "shipping_rates": Backbone.Collection,
  }
})
