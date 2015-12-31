class CountUpdateForms
  @beginListening: (isReceiving) ->
    # Edit
    $('body').on 'click', '#listing_transfer_items .fa-edit', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Spree.NumberFieldUpdater.hideReadOnly(transferItemId)
      Spree.NumberFieldUpdater.showForm(transferItemId)

    # Cancel
    $('body').on 'click', '#listing_transfer_items .fa-void', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Spree.NumberFieldUpdater.hideForm(transferItemId)
      Spree.NumberFieldUpdater.showReadOnly(transferItemId)

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
      transferItem = new Spree.TransferItem(itemAttributes)
      transferItem.update(successHandler, errorHandler)

  successHandler = (transferItem) =>
    if $('#received-transfer-items').length > 0
      Spree.NumberFieldUpdater.successHandler(transferItem.id, transferItem.received_quantity)
      Spree.StockTransfers.ReceivedCounter.updateTotal()
    else
      Spree.NumberFieldUpdater.successHandler(transferItem.id, transferItem.expected_quantity)
    show_flash("success", Spree.translations.updated_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Spree.StockTransfers ?= {}
Spree.StockTransfers.CountUpdateForms = CountUpdateForms
