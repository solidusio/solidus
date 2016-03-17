class IndexAddForms
  @beginListening: ->
    $('body').on 'click', '#listing_product_stock .fa-plus', (ev) =>
      ev.preventDefault()
      variantId = $(ev.currentTarget).data('variant-id')
      countInput = $("#variant-count-on-hand-#{variantId}")
      locationSelect = $("#variant-stock-location-#{variantId}")
      locationSelectContainer = locationSelect.siblings('.select2-container')
      resetErrors(locationSelectContainer, countInput)
      validate(locationSelect, locationSelectContainer, countInput)
      return if hasErrors(locationSelectContainer, countInput)

      stockLocationId = locationSelect.val()
      backorderable = $("#variant-backorderable-#{variantId}").prop("checked")
      stockItem = new Spree.StockItem
        variant_id: variantId
        backorderable: backorderable
        count_on_hand: countInput.val()
        stock_location_id: stockLocationId
      options =
        success: successHandler
        error: errorHandler
      stockItem.save(null, options)

  resetErrors = (locationSelectContainer, countInput) ->
    countInput.removeClass('error')
    locationSelectContainer.removeClass('error')

  validate = (locationSelect, locationSelectContainer, countInput) ->
    if locationSelect.val() is ""
      locationSelectContainer.addClass('error')

    if isNaN(parseInt(countInput.val(), 10))
      countInput.addClass('error')

  hasErrors = (locationSelectContainer, countInput) ->
    locationSelectContainer.hasClass('error') or countInput.hasClass('error')

  successHandler = (model, response, options) =>
    variantId = model.get('variant_id')
    stockLocationId = model.get('stock_location_id')
    stockLocationSelect = $("#variant-stock-location-#{variantId}")

    selectedStockLocationOption = stockLocationSelect.find("option[value='#{stockLocationId}']")
    stockLocationName = selectedStockLocationOption.text().trim()
    selectedStockLocationOption.remove()

    rowTemplate = HandlebarsTemplates['stock_items/stock_location_stock_item']
    $("tr[data-variant-id='#{variantId}']:last").before(
      rowTemplate
        id: model.get('id')
        variantId: variantId
        stockLocationId: stockLocationId
        stockLocationName: stockLocationName
        countOnHand: model.get('count_on_hand')
        backorderable: model.get('backorderable')
    )
    resetTableRowStyling(variantId)

    if stockLocationSelect.find('option').length is 1 # blank value
      stockLocationSelect.parents('tr:first').remove()
    else
      stockLocationSelect.select2()
      $("#variant-count-on-hand-#{variantId}").val("")
      $("#variant-backorderable-#{variantId}").prop("checked", false)

    resetParentRowspan(variantId)
    show_flash("success", Spree.translations.created_successfully)

  errorHandler = (model, response, options) =>
    show_flash("error", response.responseText)

  resetTableRowStyling = (variantId) ->
    tableRows = $("tr[data-variant-id='#{variantId}']")
    tableRows.removeClass('even odd')
    for i in [0..tableRows.length]
      rowClass = if (i + 1) % 2 is 0 then 'even' else 'odd'
      tableRows.eq(i).addClass(rowClass)

  resetParentRowspan = (variantId) ->
    newRowspan = $("tr[data-variant-id='#{variantId}']").length + 1
    $("#spree_variant_#{variantId} > td").attr('rowspan', newRowspan)

Spree.StockManagement ?= {}
Spree.StockManagement.IndexAddForms = IndexAddForms
