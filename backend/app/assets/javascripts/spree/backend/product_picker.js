$.fn.productAutocomplete = function (options) {
  'use strict';

  // Default options
  options = options || {}
  var multiple = typeof(options['multiple']) !== 'undefined' ? options['multiple'] : true

  function formatProduct(product) {
    return Select2.util.escapeMarkup(product.name);
  }

  this.select2({
    minimumInputLength: 3,
    multiple: multiple,
    initSelection: function (element, callback) {
      $.get(Spree.pathFor('admin/search/products'), {
        ids: element.val().split(','),
        token: Spree.api_key
      }, function (data) {
        callback(multiple ? data.products : data.products[0]);
      });
    },
    ajax: {
      url: Spree.pathFor('admin/search/products'),
      datatype: 'json',
      params: { "headers": {  'Authorization': 'Bearer ' + Spree.api_key } },
      data: function (term, page) {
        return {
          q: {
            name_cont: term,
            variants_including_master_sku_start: term,
            m: 'or'
          },
          token: Spree.api_key,
          page: page
        };
      },
      results: function (data, page) {
        var products = data.products ? data.products : [];
        return {
          results: products,
          more: (data.current_page * data.per_page) < data.total_count
        };
      }
    },
    formatResult: formatProduct,
    formatSelection: formatProduct
  });
};

Spree.ready(function () {
  $('.product_picker').productAutocomplete();
});
