/**
  * Make the element a select2 dropdown used for finding Products. By default,
  * it allows the Products to be found by its name and its Variants' SKUs.
  * @param  {Object} options Options
  * @param  {Boolean} [options.multiple=true] Allow multiple products to be selectable
  * @param  {Function|undefined} options.searchParameters Returns a hash object for params to merge on the select2 ajax request
  *                                                       Accepts an argument of the select2 search term. To use custom Ransack
  *                                                       define q on the hash and add your custom terms. Note, you need to
  *                                                       ensure that the attributes are allowed to be Ransacked.
  */
$.fn.productAutocomplete = function (options) {
  'use strict';

  // Default options
  options = options || {}
  var multiple = typeof(options['multiple']) !== 'undefined' ? options['multiple'] : true
  function extraParameters(term) {
    if (typeof(options['searchParameters']) === 'function') {
      return options['searchParameters'](term)
    }

    return {
      q: {
        name_cont: term,
        variants_including_master_sku_start: term,
        m: 'or'
      }
    }
  }

  function formatProduct(product) {
    return Select2.util.escapeMarkup(product.name);
  }

  this.select2({
    minimumInputLength: 3,
    multiple: multiple,
    quietMillis: 500,
    initSelection: function (element, callback) {
      $.get(Spree.pathFor('admin/search/products'), {
        ids: element.val().split(','),
        token: Spree.api_key,
        show_all: true
      }, function (data) {
        callback(multiple ? data.products : data.products[0]);
      });
    },
    ajax: {
      url: Spree.pathFor('admin/search/products'),
      datatype: 'json',
      params: { "headers": {  'Authorization': 'Bearer ' + Spree.api_key } },
      data: function (term, page) {
        const params = {
          token: Spree.api_key,
          page: page
        };
        return _.extend(params, extraParameters(term));
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
