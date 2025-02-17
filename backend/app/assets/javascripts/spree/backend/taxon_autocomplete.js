$.fn.taxonAutocomplete = function (options) {
  'use strict';

  var defaultOptions = {
    multiple: true,
    placeholder: Spree.translations.taxon_placeholder
  };

  options = $.extend({}, defaultOptions, options);

  this.select2({
      placeholder: options.placeholder,
      multiple: options.multiple,
      initSelection: function (element, callback) {
        var ids = element.val();

        if (options.multiple) {
          var count = ids.split(",").length;

          Spree.ajax({
            type: "GET",
            url: Spree.pathFor('api/taxons'),
            data: {
              ids: ids,
              per_page: count,
              without_children: true
            },
            success: function (data) {
              callback(data['taxons']);
            }
          });
        } else {

          Spree.ajax({
            type: "GET",
            url: Spree.pathFor('api/taxons'),
            data: {
              ids: ids,
              per_page: 1,
              without_children: true
            },
            success: function (data) {
              callback(data['taxons'][0]);
            }
          });
        }
      },
      ajax: {
        url: Spree.pathFor('api/taxons'),
        datatype: 'json',
        data: function (term, page) {
          return {
            per_page: 50,
            page: page,
            without_children: true,
            q: {
              name_cont: term
            },
            token: Spree.api_key
          };
        },
        results: function (data, page) {
          var more = page < data.pages;
          return {
            results: data['taxons'],
            more: more
          };
        }
      },
      formatResult: function (taxon, container, query, escapeMarkup) {
        return escapeMarkup(taxon.pretty_name);
      },
      formatSelection: function (taxon, container, escapeMarkup) {
        return escapeMarkup(taxon.pretty_name);
      }
    });
};

Spree.ready(function () {
  $('#product_taxon_ids, .taxon_picker').taxonAutocomplete({
    multiple: true,
  });

  $('#product_primary_taxon_id').taxonAutocomplete({
    multiple: false,
  });
});
