(function() {
  var variantTemplate = HandlebarsTemplates["variants/autocomplete"];

  var formatVariantResult = function(variant) {
    return variantTemplate({
      variant: variant
    });
  };

  $.fn.variantAutocomplete = function(searchOptions) {
    if (searchOptions == null) {
      searchOptions = {};
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
          return _.extend(searchData, searchOptions);
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
