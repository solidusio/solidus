//= require spree/backend/routes
//= require spree/backend/collections/line_items
//= require spree/backend/collections/shipments
//= require spree/backend/models/address

Spree.Models.Order = Backbone.Model.extend({
  urlRoot: Spree.pathFor('api/orders'),
  idAttribute: "number",

  relations: {
    "line_items": Spree.Collections.LineItems,
    "shipments": Spree.Collections.Shipments,
    "bill_address": Spree.Models.Address,
    "ship_address": Spree.Models.Address
  },

  advance: function(opts) {
    var options = {
      url: Spree.pathFor('api/checkouts/' + this.id + '/advance'),
      type: 'PUT',
    };
    _.extend(options, opts);
    return this.fetch(options)
  },

  empty: function (opts) {
    var options = {
      url: Spree.pathFor('api/orders/' + this.id + '/empty'),
      type: 'PUT',
    };
    _.extend(options, opts);
    return this.fetch(options)
  }
});

Spree.Models.Order.fetch = function(number, opts) {
  var options = (opts || {});
  var model = new Spree.Models.Order({
    number: number,
    line_items: [],
    shipments: [],
    bill_address: {},
    ship_address: {},
  });
  model.fetch(options);
  return model;
}
