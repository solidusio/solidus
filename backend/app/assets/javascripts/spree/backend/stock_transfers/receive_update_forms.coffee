class ReceiveUpdateForms
  @beginListening: ->
    # Edit
    $('body').on 'click', '#listing_received_transfer_items .fa-edit', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Spree.NumberFieldUpdater.hideReadOnly(transferItemId)
      Spree.NumberFieldUpdater.showForm(transferItemId)

    # Cancel
    $('body').on 'click', '#listing_received_transfer_items .fa-void', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Spree.NumberFieldUpdater.hideForm(transferItemId)
      Spree.NumberFieldUpdater.showReadOnly(transferItemId)

    # Submit
    $('body').on 'click', '#listing_received_transfer_items .fa-check', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      stockTransferNumber = $("#stock_transfer_number").val()
      receivedQuantity = parseInt($("#number-update-#{transferItemId} input[type='number']").val(), 10)

      transferItem = new Spree.TransferItem
        id: transferItemId
        stockTransferNumber: stockTransferNumber
        receivedQuantity: receivedQuantity
      transferItem.update(successHandler, errorHandler)

  successHandler = (transferItem) =>
    Spree.NumberFieldUpdater.successHandler(transferItem.id, transferItem.received_quantity)
    Spree.StockTransfers.ReceivedCounter.updateTotal()
    show_flash("success", Spree.translations.updated_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Spree.StockTransfers ?= {}
Spree.StockTransfers.ReceiveUpdateForms = ReceiveUpdateForms
