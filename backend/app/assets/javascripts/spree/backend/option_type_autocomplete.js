Spree.ready(function () {
  'use strict';

  function formatOptionType(option_type) {
    return Select2.util.escapeMarkup(option_type.presentation + ' (' + option_type.name + ')');
  }

  if ($('#product_option_type_ids').length > 0) {
    $('#product_option_type_ids').select2({
      placeholder: Spree.translations.option_type_placeholder,
      multiple: true,
      initSelection: function (element, callback) {
        return Spree.ajax({
          url: Spree.routes.option_type_search,
          data: { ids: element.val() },
          type: 'get',
          success: function(data) {
            return callback(data);
          }
        });
      },
      ajax: {
        url: Spree.routes.option_type_search,
        quietMillis: 200,
        datatype: 'json',
        params: { "headers": {  'Authorization': 'Bearer ' + Spree.api_key } },
        data: function (term) {
          return {
            q: { name_cont: term }
          };
        },
        results: function (data) {
          return {
            results: data
          };
        }
      },
      formatResult: formatOptionType,
      formatSelection: formatOptionType
    });
  }
});
