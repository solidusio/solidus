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
        variantId: variantId
        backorderable: backorderable
        countOnHand: countInput.val()
        stockLocationId: stockLocationId
      stockItem.save(successHandler, errorHandler)

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

  successHandler = (stockItem) =>
    variantId = stockItem.variant_id
    stockLocationId = stockItem.stock_location_id
    stockLocationSelect = $("#variant-stock-location-#{variantId}")

    selectedStockLocationOption = stockLocationSelect.find("option[value='#{stockLocationId}']")
    stockLocationName = selectedStockLocationOption.text().trim()
    selectedStockLocationOption.remove()

    rowTemplate = Handlebars.compile($('#stock-item-count-for-location-template').html())
    $("tr[data-variant-id='#{variantId}']:last").before(
      rowTemplate
        id: stockItem.id
        variantId: variantId
        stockLocationId: stockLocationId
        stockLocationName: stockLocationName
        countOnHand: stockItem.count_on_hand
        backorderable: stockItem.backorderable
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

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

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
