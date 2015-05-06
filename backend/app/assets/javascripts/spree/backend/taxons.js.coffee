$(document).ready ->
  $('#taxon_products').sortable();
  $('#taxon_products').on "sortstop", (event, ui) ->
    Spree.ajax
      url: Spree.routes.classifications_api,
      method: 'PUT',
      data:
        product_id: ui.item.data('product-id'),
        taxon_id: $('#taxon_id').val(),
        position: ui.item.index()

  window.productTemplate = Handlebars.compile($('#product_template_sortable').text());

  productListTemplate = (products) ->
    products.map(productTemplate).join('') ||
    "<h4>#{Spree.translations.no_results}</h4>"

  $('#taxon_id').select2
    dropdownCssClass: "taxon_select_box",
    placeholder: Spree.translations.find_a_taxon,
    ajax:
      url: Spree.routes.taxons_search,
      datatype: 'json',
      params: { "headers": { "X-Spree-Token": Spree.api_key } },
      data: (term, page) ->
        per_page: 50,
        page: page,
        q:
          name_cont: term
      results: (data, page) ->
        more = page < data.pages;
        results: data['taxons'],
        more: more
    formatResult: (taxon) ->
      taxon.pretty_name;
    formatSelection: (taxon) ->
      taxon.pretty_name;

  $('#taxon_id').on "change", (e) ->
    el = $('#taxon_products')
    Spree.ajax
      url: Spree.routes.taxon_products_api,
      data: { id: e.val }
      success: (data) ->
        el.html productListTemplate(data.products)
