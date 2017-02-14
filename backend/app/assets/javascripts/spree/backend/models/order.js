//= require spree/backend/routes

Spree.Models || (Spree.Models = {});

Spree.Models.Order = Backbone.Model.extend({
  urlRoot: Spree.routes.orders_api,
  idAttribute: "number",

  advance: function(opts) {
    var options = {
      url: Spree.routes.checkouts_api + "/" + this.id + "/advance",
      type: 'PUT',
    };
    _.extend(options, opts);
    return this.fetch(options)
  }
});
