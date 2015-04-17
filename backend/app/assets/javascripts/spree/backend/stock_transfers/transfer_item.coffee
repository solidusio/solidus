class TransferItem
  constructor: (options = {}) ->
    @id = options.id
    @variantId = options.variantId
    @receivedQuantity = options.receivedQuantity
    @stockTransferNumber = options.stockTransferNumber

  save: (successHandler, errorHandler) ->
    Spree.ajax
      url: Spree.routes.receive_transfer_items_api(@stockTransferNumber)
      type: "POST"
      data:
        variant_id: @variantId
      success: (transferItem) ->
        successHandler(transferItem)
      error: (errorData) ->
        errorHandler(errorData)

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
