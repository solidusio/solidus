class IndexUpdateForms
  @beginListening: ->
    # Edit
    $('body').on 'click', '#listing_product_stock .fa-edit', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      hideReadOnlyElements(stockItemId)
      storeBackorderableState(stockItemId)
      resetCountOnHandInput(stockItemId)
      showEditForm(stockItemId)

    # Cancel
    $('body').on 'click', '#listing_product_stock .fa-void', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      hideEditForm(stockItemId)
      restoreBackorderableState(stockItemId)
      showReadOnlyElements(stockItemId)

    # Submit
    $('body').on 'click', '#listing_product_stock .fa-check', (ev) =>
      ev.preventDefault()
      stockItemId = $(ev.currentTarget).data('id')
      stockLocationId = $(ev.currentTarget).data('location-id')
      backorderable = $("#backorderable-#{stockItemId}").prop("checked")
      countOnHand = parseInt($("#count-on-hand-#{stockItemId} input[type='number']").val(), 10)

      stockItem = new Spree.StockItem
        id: stockItemId
        countOnHand: countOnHand
        backorderable: backorderable
        stockLocationId: stockLocationId
      stockItem.update(successHandler, errorHandler)

  showReadOnlyElements = (stockItemId) ->
    toggleReadOnlyElements(stockItemId, true)

  hideReadOnlyElements = (stockItemId) ->
    toggleReadOnlyElements(stockItemId, false)

  toggleReadOnlyElements = (stockItemId, show) ->
    disabledValue = if show then 'disabled' else null
    textCssDisplay = if show then 'block' else 'none'
    toggleButtonVisibility('edit', stockItemId, show)
    $("#backorderable-#{stockItemId}").prop('disabled', disabledValue)
    $("#count-on-hand-#{stockItemId} span").css('display', textCssDisplay)

  showEditForm = (stockItemId) ->
    toggleEditFormVisibility(stockItemId, true)

  hideEditForm = (stockItemId) ->
    toggleEditFormVisibility(stockItemId, false)

  toggleEditFormVisibility = (stockItemId, show) ->
    disabledValue = if show then null else 'disabled'
    inputCssDisplay = if show then 'block' else 'none'
    toggleButtonVisibility('void', stockItemId, show)
    toggleButtonVisibility('check', stockItemId, show)
    $("#backorderable-#{stockItemId}").prop('disabled', disabledValue)
    $("#count-on-hand-#{stockItemId} input[type='number']").css('display', inputCssDisplay)

  toggleButtonVisibility = (buttonIcon, stockItemId, show) ->
    cssDisplay = if show then 'inline-block' else 'none'
    $(".fa-#{buttonIcon}[data-id='#{stockItemId}']").css('display', cssDisplay)

  resetCountOnHandInput = (stockItemId) ->
    tableCell = $("#count-on-hand-#{stockItemId}")
    countText = tableCell.find('span').text().trim()
    tableCell.find("input[type='number']").val(countText)

  storeBackorderableState = (stockItemId) ->
    backorderableCheckbox = $("#backorderable-#{stockItemId}")
    backorderableCheckbox.parent('td').attr('data-was-checked', backorderableCheckbox.prop('checked'))

  restoreBackorderableState = (stockItemId) ->
    backorderableCheckbox = $("#backorderable-#{stockItemId}")
    backorderableCheckbox.prop('checked', backorderableCheckbox.parent('td').data('was-checked'))

  successHandler = (stockItem) =>
    $("#count-on-hand-#{stockItem.id} span").text(stockItem.count_on_hand)
    hideEditForm(stockItem.id)
    showReadOnlyElements(stockItem.id)
    show_flash("success", Spree.translations.updated_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Spree.StockManagement ?= {}
Spree.StockManagement.IndexUpdateForms = IndexUpdateForms
