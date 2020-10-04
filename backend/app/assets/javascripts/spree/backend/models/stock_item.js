Spree.Models.StockItem = Backbone.Model.extend({
  paramRoot: 'stock_item',
  urlRoot: function() {
    return Spree.pathFor('api/stock_locations/' + this.get('stock_location_id') + '/stock_items');
  }
});
