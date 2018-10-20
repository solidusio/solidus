$.fn.optionValueAutocomplete = function (options) {
  'use strict';

  // Default options
  options = options || {}
  var multiple = typeof(options['multiple']) !== 'undefined' ? options['multiple'] : true;
  var productSelect = options['productSelect'];

  function formatOptionValue(option_value) {
    return Select2.util.escapeMarkup(option_value.name);
  }

  this.select2({
    minimumInputLength: 3,
    multiple: multiple,
    initSelection: function (element, callback) {
      $.get(Spree.routes.option_value_search, {
        ids: element.val().split(','),
        token: Spree.api_key
      }, function (data) {
        callback(multiple ? data : data[0]);
      });
    },
    ajax: {
      url: Spree.routes.option_value_search,
      datatype: 'json',
      data: function (term, page) {
        // Note: This doesn't work. variants_product_id isn't an allowed filter
        var productId = typeof(productSelect) !== 'undefined' ? $(productSelect).select2('val') : null;
        return {
          q: {
            name_cont: term,
            variants_product_id_eq: productId
          },
          token: Spree.api_key
        };
      },
      results: function (data, page) {
        return { results: data };
      }
    },
    formatResult: formatOptionValue,
    formatSelection: formatOptionValue
  });
};
