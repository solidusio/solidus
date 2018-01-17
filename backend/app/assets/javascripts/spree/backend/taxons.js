Spree.ready(function() {
  var productTemplate = HandlebarsTemplates['products/sortable'];
  var productListTemplate = function(products) {
    return _.map(products, productTemplate).join('') || "<h4>" + Spree.translations.no_results + "</h4>";
  };

  var saveSort = function(event, ui) {
    Spree.ajax({
      url: Spree.routes.classifications_api,
      method: 'PUT',
      data: {
        product_id: ui.item.data('product-id'),
        taxon_id: $('#taxon_id').val(),
        position: ui.item.index()
      }
    });
  };

  var sortable = $('#taxon_products').sortable().on({
    sortupdate: saveSort
  });

  var formatTaxon = function(taxon) {
    return Select2.util.escapeMarkup(taxon.pretty_name);
  };

  $('#taxon_id').select2({
    dropdownCssClass: "taxon_select_box",
    placeholder: Spree.translations.find_a_taxon,
    ajax: {
      url: Spree.routes.taxons_search,
      params: {
        "headers": {
          "X-Spree-Token": Spree.api_key
        }
      },
      data: function(term, page) {
        return {
          per_page: 50,
          page: page,
          q: {
            name_cont: term
          }
        };
      },
      results: function(data) {
        return {
          results: data['taxons'],
          more: data.current_page < data.pages
        };
      }
    },
    formatResult: formatTaxon,
    formatSelection: formatTaxon
  });

  $('#taxon_id').on("change", function(e) {
    Spree.ajax({
      url: Spree.routes.taxon_products_api,
      data: {
        id: e.val,
        simple: 1
      },
      success: function(data) {
        sortable.html(productListTemplate(data.products));
      }
    });
  });
});
