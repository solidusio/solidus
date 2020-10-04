Spree.Models.Payment = Backbone.Model.extend({
  urlRoot: function() {
    return Spree.pathFor('api/orders/' + this.get('order_id') + '/payments')
  }
});
