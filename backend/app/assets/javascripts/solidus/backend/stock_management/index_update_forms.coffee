class IndexUpdateForms
  @beginListening: ->
    # Edit
    $('body').on 'click', '#listing_product_stock .fa-edit', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      storeBackorderableState(stockItemId)
      Solidus.NumberFieldUpdater.hideReadOnly(stockItemId)
      showEditForm(stockItemId)

    # Cancel
    $('body').on 'click', '#listing_product_stock .fa-void', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      restoreBackorderableState(stockItemId)
      Solidus.NumberFieldUpdater.hideForm(stockItemId)
      showReadOnlyElements(stockItemId)

    # Submit
    $('body').on 'click', '#listing_product_stock .fa-check', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      stockLocationId = $(ev.currentTarget).data('location-id')
      backorderable = $("#backorderable-#{stockItemId}").prop("checked")
      countOnHand = parseInt($("#number-update-#{stockItemId} input[type='number']").val(), 10)

      stockItem = new Solidus.StockItem
        id: stockItemId
        countOnHand: countOnHand
        backorderable: backorderable
        stockLocationId: stockLocationId
      stockItem.update(successHandler, errorHandler)

  showReadOnlyElements = (stockItemId) ->
    toggleBackorderable(stockItemId, false)
    Solidus.NumberFieldUpdater.showReadOnly(stockItemId)

  showEditForm = (stockItemId) ->
    toggleBackorderable(stockItemId, true)
    Solidus.NumberFieldUpdater.showForm(stockItemId)

  toggleBackorderable = (stockItemId, show) ->
    disabledValue = if show then null else 'disabled'
    $("#backorderable-#{stockItemId}").prop('disabled', disabledValue)

  storeBackorderableState = (stockItemId) ->
    backorderableCheckbox = $("#backorderable-#{stockItemId}")
    backorderableCheckbox.parent('td').attr('was-checked', backorderableCheckbox.prop('checked'))

  restoreBackorderableState = (stockItemId) ->
    backorderableCheckbox = $("#backorderable-#{stockItemId}")
    checked = backorderableCheckbox.parent('td').attr('was-checked') is "true"
    backorderableCheckbox.prop('checked', checked)

  successHandler = (stockItem) =>
    toggleBackorderable(stockItem.id, false)
    Solidus.NumberFieldUpdater.successHandler(stockItem.id, stockItem.count_on_hand)
    show_flash("success", Solidus.translations.updated_successfully)

  errorHandler = (errorData) ->
    show_flash("error", errorData.responseText)

Solidus.StockManagement ?= {}
Solidus.StockManagement.IndexUpdateForms = IndexUpdateForms
