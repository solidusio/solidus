//= require solidus_admin/Sortable

Spree.ready(function() {
  var productTemplate = HandlebarsTemplates['products/sortable'];
  var productListTemplate = function(products) {
    return _.map(products, productTemplate).join('') || "<h4>" + Spree.translations.no_results + "</h4>";
  };

  var saveSort = function(e) {
    var item = e.item;
    Spree.ajax({
      url: Spree.pathFor('api/classifications'),
      method: 'PUT',
      data: {
        product_id: item.getAttribute('data-product-id'),
        taxon_id: $('#taxon_id').val(),
        position: e.newIndex
      }
    });
  };

  var formatTaxon = function(taxon) {
    return Select2.util.escapeMarkup(taxon.pretty_name);
  };

  $('#taxon_id').select2({
    dropdownCssClass: "taxon_select_box",
    placeholder: Spree.translations.find_a_taxon,
    ajax: {
      url: Spree.pathFor('api/taxons'),
      params: {
        "headers": {
          'Authorization': 'Bearer ' + Spree.api_key
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
      url: Spree.pathFor('api/taxons/products'),
      data: {
        id: e.val,
        simple: 1
      },
      success: function(data) {
        $('#taxon_products').html(productListTemplate(data.products));

        var el = document.querySelector('#taxon_products')

        new Sortable(el, {
          draggable: ".sort_item",
          onEnd: saveSort
        });
      }
    });
  });
});
