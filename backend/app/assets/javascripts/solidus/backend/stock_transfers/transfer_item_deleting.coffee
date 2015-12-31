class TransferItemDeleting
  @beginListening: ->
    $('body').on 'click', '#listing_transfer_items .fa-trash', (ev) =>
      ev.preventDefault()
      if confirm(Solidus.translations.are_you_sure_delete)
        transferItemId = $(ev.currentTarget).data('id')
        stockTransferNumber = $("#stock_transfer_number").val()

        transferItem = new Solidus.TransferItem
          id: transferItemId
          stockTransferNumber: stockTransferNumber
        transferItem.destroy(successHandler, errorHandler)

  successHandler = (transferItem) =>
    $("[data-transfer-item-id='#{transferItem.id}']").remove()
    show_flash("success", Solidus.translations.deleted_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Solidus.StockTransfers ?= {}
Solidus.StockTransfers.TransferItemDeleting = TransferItemDeleting
