Spree.Models.StockItem = Backbone.Model.extend({
  paramRoot: 'stock_item',
  urlRoot: function() {
    return Spree.routes.stock_items_api(this.get('stock_location_id'));
  }
});
