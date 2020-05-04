Spree.Models.Shipment = Backbone.Model.extend({
  idAttribute: "number",
  paramRoot: "shipment",
  urlRoot: Spree.pathFor('api/shipments'),

  relations: {
    "selected_shipping_rate": Backbone.Model,
    "shipping_rates": Backbone.Collection,
  },

  estimatedRates: function() {
    var ratesCollection = Backbone.Collection.extend({
      parse: function(resp){ return resp.shipping_rates }
    });
    var rates = new ratesCollection();
    rates.fetch({ url: this.url() + "/estimated_rates" })
    return rates;
  },

  selectShippingMethodId: function(shippingMethodId, options) {
    this.sync("update", this, _.extend({
      url: this.url() + "/select_shipping_method",
      contentType: 'application/json',
      data: JSON.stringify({ shipping_method_id: shippingMethodId })
    }, options));
  }
})
