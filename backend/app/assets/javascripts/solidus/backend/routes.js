Solidus.routes.checkouts_api = Solidus.pathFor('api/checkouts')
Solidus.routes.classifications_api = Solidus.pathFor('api/classifications')
Solidus.routes.clear_cache = Solidus.pathFor('admin/general_settings/clear_cache')
Solidus.routes.option_value_search = Solidus.pathFor('api/option_values')
Solidus.routes.option_type_search = Solidus.pathFor('api/option_types')
Solidus.routes.orders_api = Solidus.pathFor('api/orders')
Solidus.routes.product_search = Solidus.pathFor('api/products')
Solidus.routes.admin_product_search = Solidus.pathFor('admin/search/products')
Solidus.routes.shipments_api = Solidus.pathFor('api/shipments')
Solidus.routes.checkouts_api = Solidus.pathFor('api/checkouts')
Solidus.routes.stock_locations_api = Solidus.pathFor('api/stock_locations')
Solidus.routes.taxon_products_api = Solidus.pathFor('api/taxons/products')
Solidus.routes.taxons_search = Solidus.pathFor('api/taxons')
Solidus.routes.user_search = Solidus.pathFor('admin/search/users')
Solidus.routes.variants_api = Solidus.pathFor('api/variants')

Solidus.routes.line_items_api = function(order_id) {
  return Solidus.pathFor('api/orders/' + order_id + '/line_items')
}

Solidus.routes.payments_api = function(order_id) {
  return Solidus.pathFor('api/orders/' + order_id + '/payments')
}

Solidus.routes.stock_items_api = function(stock_location_id) {
  return Solidus.pathFor('api/stock_locations/' + stock_location_id + '/stock_items')
}

Solidus.routes.receive_stock_transfer_api = function(stockTransferNumber) {
  return Solidus.pathFor('api/stock_transfers/' + stockTransferNumber + '/receive')
}

Solidus.routes.create_transfer_items_api = function(stockTransferNumber) {
  return Solidus.pathFor('api/stock_transfers/' + stockTransferNumber + '/transfer_items')
}

Solidus.routes.update_transfer_items_api = function(stockTransferNumber, itemId) {
  return Solidus.pathFor('api/stock_transfers/' + stockTransferNumber + '/transfer_items/' + itemId)
}
