/**
 * @deprecated Spree.routes will be removed in a future release. Please use Spree.pathFor instead.
 * See: https://github.com/solidusio/solidus/issues/3405
 */

var admin_routes = {
  classifications_api: Spree.pathFor('api/classifications'),
  option_value_search: Spree.pathFor('api/option_values'),
  option_type_search: Spree.pathFor('api/option_types'),
  orders_api: Spree.pathFor('api/orders'),
  product_search: Spree.pathFor('api/products'),
  admin_product_search: Spree.pathFor('admin/search/products'),
  shipments_api: Spree.pathFor('api/shipments'),
  checkouts_api: Spree.pathFor('api/checkouts'),
  stock_locations_api: Spree.pathFor('api/stock_locations'),
  taxon_products_api: Spree.pathFor('api/taxons/products'),
  taxons_search: Spree.pathFor('api/taxons'),
  user_search: Spree.pathFor('admin/search/users'),
  variants_api: Spree.pathFor('api/variants'),
  users_api: Spree.pathFor('api/users'),

  line_items_api: function(order_id) {
    return Spree.pathFor('api/orders/' + order_id + '/line_items')
  },

  payments_api: function(order_id) {
    return Spree.pathFor('api/orders/' + order_id + '/payments')
  },

  stock_items_api: function(stock_location_id) {
    return Spree.pathFor('api/stock_locations/' + stock_location_id + '/stock_items')
  }
}

var frontend_routes = {
  states_search: Spree.pathFor('api/states'),
  apply_coupon_code: function(order_id) {
    return Spree.pathFor("api/orders/" + order_id + "/coupon_codes");
  }
}

if(typeof Proxy == "function") {
  Spree.routes = new Proxy(Object.assign(admin_routes, frontend_routes), Spree.routesDeprecationProxy);
} else {
  Object.assign(Spree.routes, admin_routes)
}
