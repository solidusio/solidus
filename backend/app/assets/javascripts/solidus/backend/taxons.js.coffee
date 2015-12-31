$ ->
  productTemplate = HandlebarsTemplates['products/sortable']

  productListTemplate = (products) ->
    products.map(productTemplate).join('') ||
    "<h4>#{Solidus.translations.no_results}</h4>"

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
   Solidus.ajax
     url: Solidus.routes.classifications_api,
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

  $('#taxon_id').select2
    dropdownCssClass: "taxon_select_box",
    placeholder: Solidus.translations.find_a_taxon,
    ajax:
      url: Solidus.routes.taxons_search,
      params: { "headers": { "X-Solidus-Token": Solidus.api_key } },
      data: (term, page) ->
        per_page: 50,
        page: page,
        q:
          name_cont: term
      results: (data) ->
        results: data['taxons'],
        more: data.current_page < data.pages
    formatResult: (taxon) ->
      taxon.pretty_name
    formatSelection: (taxon) ->
      taxon.pretty_name

  $('#taxon_id').on "change", (e) ->
    Solidus.ajax
      url: Solidus.routes.taxon_products_api,
      data: { id: e.val }
      success: (data) ->
        sortable.html productListTemplate(data.products)
