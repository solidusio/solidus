Spree.routes.checkouts_api = Spree.pathFor('api/checkouts')
Spree.routes.classifications_api = Spree.pathFor('api/classifications')
Spree.routes.option_value_search = Spree.pathFor('api/option_values')
Spree.routes.option_type_search = Spree.pathFor('api/option_types')
Spree.routes.orders_api = Spree.pathFor('api/orders')
Spree.routes.product_search = Spree.pathFor('api/products')
Spree.routes.admin_product_search = Spree.pathFor('admin/search/products')
Spree.routes.shipments_api = Spree.pathFor('api/shipments')
Spree.routes.checkouts_api = Spree.pathFor('api/checkouts')
Spree.routes.stock_locations_api = Spree.pathFor('api/stock_locations')
Spree.routes.taxon_products_api = Spree.pathFor('api/taxons/products')
Spree.routes.taxons_search = Spree.pathFor('api/taxons')
Spree.routes.user_search = Spree.pathFor('admin/search/users')
Spree.routes.variants_api = Spree.pathFor('api/variants')
Spree.routes.users_api = Spree.pathFor('api/users')

Spree.routes.line_items_api = function(order_id) {
  return Spree.pathFor('api/orders/' + order_id + '/line_items')
}

Spree.routes.payments_api = function(order_id) {
  return Spree.pathFor('api/orders/' + order_id + '/payments')
}

Spree.routes.stock_items_api = function(stock_location_id) {
  return Spree.pathFor('api/stock_locations/' + stock_location_id + '/stock_items')
}
