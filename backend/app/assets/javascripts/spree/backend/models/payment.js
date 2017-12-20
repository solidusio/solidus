Spree.Models.Payment = Backbone.Model.extend({
  urlRoot: function() {
    return Spree.routes.payments_api(this.get('order_id'));
  }
});
