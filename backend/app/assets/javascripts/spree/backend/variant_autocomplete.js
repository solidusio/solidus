(function() {
  var variantTemplate = HandlebarsTemplates["variants/autocomplete"];

  var formatVariantResult = function(variant) {
    return variantTemplate({
      variant: variant
    });
  };

  /**
    * Make the element a select2 dropdown used for finding Variants. By default, the search term will be
    * passed to the defined Spree::Config.variant_search_class by the controller with its defined scope.
    * @param  {Object|undefined|null} options Options to be passed to select2. If null, the default options will be used.
    * @param  {Function|undefined} options.searchParameters Returns a hash object for params to merge on the select2 ajax request
    *                                                       Accepts an argument of the select2 search term. To use Ransack, define
    *                                                       variant_search_term as a falsy value, and q as the Ransack query. Note,
    *                                                       you need to ensure that the attributes are allowed to be Ransacked.
    */
  $.fn.variantAutocomplete = function(options = {}) {
    // Default options
    const searchParameters = options.searchParameters || null
    delete options.searchParameters
    const select2options = options
    const defaultOptions = {
      placeholder: Spree.translations.variant_placeholder,
      minimumInputLength: 3,
      initSelection: function(element, callback) {
        Spree.ajax({
          url: Spree.pathFor('api/variants/' + element.val()),
          success: callback
        });
      },
      ajax: {
        url: Spree.pathFor('api/variants'),
        datatype: "json",
        quietMillis: 500,
        params: {
          "headers": {
            'Authorization': 'Bearer ' + Spree.api_key
          }
        },
        data: function(term, page) {
          const extraParameters = searchParameters ? searchParameters(term) : {}

          return {
            variant_search_term: term,
            token: Spree.api_key,
            page: page,
            ...extraParameters,
          }
        },
        results: function(data, page) {
          window.variants = data["variants"];
          return {
            results: data["variants"],
            more: data.current_page * data.per_page < data.total_count
          };
        }
      },

      formatResult: formatVariantResult,
      formatSelection: function(variant, container, escapeMarkup) {
        if (variant.options_text) {
          return Select2.util.escapeMarkup(variant.name + " (" + variant.options_text + ")");
        } else {
          return Select2.util.escapeMarkup(variant.name);
        }
      },
    }

    this.select2(Object.assign({}, defaultOptions, select2options));
  };
})();
