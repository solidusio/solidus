$.fn.taxonAutocomplete = function () {
  'use strict';

  this.select2({
      placeholder: Spree.translations.taxon_placeholder,
      multiple: true,
      initSelection: function (element, callback) {
        Spree.ajax({
          type: "GET",
          url: Spree.routes.taxons_search,
          data: {
            ids: element.val(),
            without_children: true
          },
          success: function (data) {
            callback(data['taxons']);
          }
        });
      },
      ajax: {
        url: Spree.routes.taxons_search,
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

$(document).ready(function () {
  $('#product_taxon_ids, .taxon_picker').taxonAutocomplete();
});

// for backwards compat...
var set_taxon_select = function() {
  $('#product_taxon_ids, .taxon_picker').taxonAutocomplete();
}
