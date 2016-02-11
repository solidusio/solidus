'use strict';

var set_taxon_select = function(){
  if ($('#product_taxon_ids').length > 0) {
    $('#product_taxon_ids').select2({
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
        params: { "headers": { "X-Spree-Token": Spree.api_key } },
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
      formatResult: function (taxon) {
        return taxon.pretty_name;
      },
      formatSelection: function (taxon) {
        return taxon.pretty_name;
      }
    });
  }
}

$(document).ready(function () {
  set_taxon_select()
});
