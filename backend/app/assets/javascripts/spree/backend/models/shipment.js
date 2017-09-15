Spree.Models.Shipment = Backbone.Model.extend({
  idAttribute: "number",

  relations: {
    "selected_shipping_rate": Backbone.Model,
    "shipping_rates": Backbone.Collection,
  }
})
