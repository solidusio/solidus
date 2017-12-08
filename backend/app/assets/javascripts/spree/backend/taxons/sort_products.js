Spree.TaxonSortProductsView = Backbone.View.extend({
  tagName: 'div',

  initialize: function(options) {
    this.setElement(options.$el);
    this.products = options.products;
    this.render()
  },

  template: HandlebarsTemplates['products/sortable_list'],

  render: function() {
    this.$el.html(this.template({
      noResults: Spree.translations.no_results,
      products: this.products
    }));
    $('#taxon_products').sortable()
      .on({
        sortstart: this.focusDraggable,
        sortstop: this.focusDraggable,
        sortupdate: this.saveSort,
      })
      .on({
        click: this.focusDraggable,
        keydown: this.moveDraggable
        }, '.sort_item'
      );
  },

  raiseDraggable: function (draggable) {
    draggable.prev().insertAfter(draggable);
    sortupdate(draggable);
  },

  lowerDraggable: function (draggable) {
    draggable.next().insertBefore(draggable);
    sortupdate(draggable);
  },

  focusDraggable: function (e) {
    $(e.srcElement).focus();
  },

  moveDraggable: function (e) {
    if (e.keyCode == $.ui.keyCode.UP) {
      this.raiseDraggable($(e.currentTarget));
    } else if (e.keyCode == $.ui.keyCode.DOWN) {
      this.lowerDraggable($(e.currentTarget));
    }
  },

  saveSort: function (event, ui) {
    Spree.ajax({
      url: Spree.routes.classifications_api,
      method: 'PUT',
      data: {
        product_id: ui.item.data('product-id'),
        taxon_id: $('#taxon_id').val(),
        position: ui.item.index()
      }
    })
  },

  sortupdate: _.debounce(function(draggable) {
    this.sortable.trigger('sortupdate', {item: draggable});
    }, 250
    )
});

function formatTaxon(taxon) {
  return Select2.util.escapeMarkup(taxon.pretty_name)
}

Spree.ready(function() {
  $('#taxon_id').select2({
    dropdownCssClass: "taxon_select_box",
    placeholder: Spree.translations.find_a_taxon,
    ajax: {
      url: Spree.routes.taxons_search,
      params: { "headers": { "X-Spree-Token": Spree.api_key } },
      data: function (term, page) {
        return {
          per_page: 50,
          page: page,
          q: {
            name_cont: term
          }
        }
      },
      results: function (data) {
        return {
          results: data['taxons'],
          more: (data.current_page < data.pages)
        }
      }
    },
    formatResult: formatTaxon,
    formatSelection: formatTaxon
  });

  $('#taxon_id').on("change", function (e) {
    Spree.ajax({
      url: Spree.routes.taxon_products_api,
      data: { id: e.val, simple: 1 },
      success: function (data) {
        return new Spree.TaxonSortProductsView({
          $el: $('#taxon_products'),
          products: data.products
        });
      }
    });
  });
})