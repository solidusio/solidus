class IndexUpdateForms
  @beginListening: ->
    # Edit
    $('body').on 'click', '#listing_product_stock .fa-edit', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      storeBackorderableState(stockItemId)
      Spree.NumberFieldUpdater.hideReadOnly(stockItemId)
      showEditForm(stockItemId)

    # Cancel
    $('body').on 'click', '#listing_product_stock .fa-void', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      restoreBackorderableState(stockItemId)
      Spree.NumberFieldUpdater.hideForm(stockItemId)
      showReadOnlyElements(stockItemId)

    # Submit
    $('body').on 'click', '#listing_product_stock .fa-check', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      stockLocationId = $(ev.currentTarget).data('location-id')
      backorderable = $("#backorderable-#{stockItemId}").prop("checked")
      countOnHand = parseInt($("#number-update-#{stockItemId} input[type='number']").val(), 10)

      stockItem = new Spree.StockItem
        id: stockItemId
        count_on_hand: countOnHand
        backorderable: backorderable
        stock_location_id: stockLocationId
      options =
        success: successHandler
        error: errorHandler
      stockItem.save(force: true, options)

  showReadOnlyElements = (stockItemId) ->
    toggleBackorderable(stockItemId, false)
    Spree.NumberFieldUpdater.showReadOnly(stockItemId)

  showEditForm = (stockItemId) ->
    toggleBackorderable(stockItemId, true)
    Spree.NumberFieldUpdater.showForm(stockItemId)

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

  successHandler = (model, response, options) =>
    toggleBackorderable(model.get('id'), false)
    Spree.NumberFieldUpdater.successHandler(model.get('id'), model.get('count_on_hand'))
    show_flash("success", Spree.translations.updated_successfully)

  errorHandler = (model, response, options) ->
    show_flash("error", response.responseText)

Spree.StockManagement ?= {}
Spree.StockManagement.IndexUpdateForms = IndexUpdateForms
