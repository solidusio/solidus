$ ->
  productTemplate = HandlebarsTemplates['products/sortable']

  productListTemplate = (products) ->
    products.map(productTemplate).join('') ||
    "<h4>#{Spree.translations.no_results}</h4>"

  raiseDraggable = (draggable) ->
    draggable.prev().insertAfter(draggable)
    sortupdate(draggable)

  lowerDraggable = (draggable) ->
    draggable.next().insertBefore(draggable)
    sortupdate(draggable)

  focusDraggable = (e) ->
    $(e.srcElement).focus()

  moveDraggable = (e) ->
    if e.keyCode == $.ui.keyCode.UP
      raiseDraggable $(e.currentTarget)
    else if e.keyCode == $.ui.keyCode.DOWN
      lowerDraggable $(e.currentTarget)

  saveSort = (event, ui) ->
   Spree.ajax
     url: Spree.routes.classifications_api,
     method: 'PUT',
     data:
       product_id: ui.item.data('product-id'),
       taxon_id: $('#taxon_id').val(),
       position: ui.item.index()

  sortable = $('#taxon_products').sortable()
    .on
      sortstart: focusDraggable
      sortstop: focusDraggable
      sortupdate: saveSort
    .on
      click: focusDraggable
      keydown: moveDraggable
    , '.sort_item'

  sortupdate = _.debounce (draggable) ->
    sortable.trigger('sortupdate', item: draggable)
  , 250

  formatTaxon = (taxon) ->
    Select2.util.escapeMarkup(taxon.pretty_name)

  $('#taxon_id').select2
    dropdownCssClass: "taxon_select_box",
    placeholder: Spree.translations.find_a_taxon,
    ajax:
      url: Spree.routes.taxons_search,
      params: { "headers": { "X-Spree-Token": Spree.api_key } },
      data: (term, page) ->
        per_page: 50,
        page: page,
        q:
          name_cont: term
      results: (data) ->
        results: data['taxons'],
        more: data.current_page < data.pages
    formatResult: formatTaxon,
    formatSelection: formatTaxon

  $('#taxon_id').on "change", (e) ->
    Spree.ajax
      url: Spree.routes.taxon_products_api,
      data: { id: e.val }
      success: (data) ->
        sortable.html productListTemplate(data.products)
