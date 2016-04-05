Spree.StockItem = Backbone.Model.extend
  urlRoot: ->
    Spree.routes.stock_items_api(@get('stock_location_id'))
  paramRoot: 'stock_item'
