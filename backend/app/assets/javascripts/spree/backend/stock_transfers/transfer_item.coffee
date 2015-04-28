class TransferItem
  constructor: (options = {}) ->
    @id = options.id
    @receivedQuantity = options.receivedQuantity
    @stockTransferNumber = options.stockTransferNumber

  update: (successHandler, errorHandler) ->
    Spree.ajax
      url: Spree.routes.update_transfer_items_api(@stockTransferNumber, @id)
      type: "PUT"
      data:
        transfer_item:
          received_quantity: @receivedQuantity
      success: (transferItem) ->
        successHandler(transferItem)
      error: (errorData) ->
        errorHandler(errorData)

Spree.TransferItem = TransferItem
