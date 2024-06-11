Spree.ready(function() {
  if ($('[data-hook="admin_products_index_search"]').length) {
    new Spree.Views.Product.Search({
      el: $('[data-hook="admin_products_index_search"]')
    })
  }
});
