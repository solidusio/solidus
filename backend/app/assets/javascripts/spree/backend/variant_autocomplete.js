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
    * @param  {Object} options Options
    * @param  {Function|undefined} options.searchParameters Returns a hash object for params to merge on the select2 ajax request
    *                                                       Accepts an argument of the select2 search term. To use Ransack, define
    *                                                       variant_search_term as a falsy value, and q as the Ransack query. Note,
    *                                                       you need to ensure that the attributes are allowed to be Ransacked.
    */
  $.fn.variantAutocomplete = function(options = {}) {
    function extraParameters(term) {
      if (typeof(options['searchParameters']) === 'function') {
        return options['searchParameters'](term)
      }

      return {}
    }

    this.select2({
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
          var searchData = {
            variant_search_term: term,
            token: Spree.api_key,
            page: page
          };
          return _.extend(searchData, extraParameters(term));
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
      }
    });
  };
})();
