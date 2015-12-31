class CountUpdateForms
  @beginListening: (isReceiving) ->
    # Edit
    $('body').on 'click', '#listing_transfer_items .fa-edit', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Solidus.NumberFieldUpdater.hideReadOnly(transferItemId)
      Solidus.NumberFieldUpdater.showForm(transferItemId)

    # Cancel
    $('body').on 'click', '#listing_transfer_items .fa-void', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Solidus.NumberFieldUpdater.hideForm(transferItemId)
      Solidus.NumberFieldUpdater.showReadOnly(transferItemId)

    # Submit
    $('body').on 'click', '#listing_transfer_items .fa-check', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      stockTransferNumber = $("#stock_transfer_number").val()
      quantity = parseInt($("#number-update-#{transferItemId} input[type='number']").val(), 10)

      itemAttributes =
        id: transferItemId
        stockTransferNumber: stockTransferNumber
      quantityKey = if isReceiving then 'receivedQuantity' else 'expectedQuantity'
      itemAttributes[quantityKey] = quantity
      transferItem = new Solidus.TransferItem(itemAttributes)
      transferItem.update(successHandler, errorHandler)

  successHandler = (transferItem) =>
    if $('#received-transfer-items').length > 0
      Solidus.NumberFieldUpdater.successHandler(transferItem.id, transferItem.received_quantity)
      Solidus.StockTransfers.ReceivedCounter.updateTotal()
    else
      Solidus.NumberFieldUpdater.successHandler(transferItem.id, transferItem.expected_quantity)
    show_flash("success", Solidus.translations.updated_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Solidus.StockTransfers ?= {}
Solidus.StockTransfers.CountUpdateForms = CountUpdateForms
