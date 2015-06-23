class TransferItem
  constructor: (options = {}) ->
    @id = options.id
    @variantId = options.variantId
    @receivedQuantity = options.receivedQuantity
    @expectedQuantity = options.expectedQuantity
    @stockTransferNumber = options.stockTransferNumber

  create: (successHandler, errorHandler) ->
    Spree.ajax
      url: Spree.routes.create_transfer_items_api(@stockTransferNumber)
      type: "POST"
      data:
        transfer_item:
          variant_id: @variantId
          expected_quantity: @expectedQuantity
      success: (transferItem) ->
        successHandler(transferItem)
      error: (errorData) ->
        errorHandler(errorData)

  update: (successHandler, errorHandler) ->
    itemAttrs = if @receivedQuantity?
      { received_quantity: @receivedQuantity }
    else if @expectedQuantity?
      { expected_quantity: @expectedQuantity }
    else
      {}
    Spree.ajax
      url: Spree.routes.update_transfer_items_api(@stockTransferNumber, @id)
      type: "PUT"
      data:
        transfer_item: itemAttrs
      success: (transferItem) ->
        successHandler(transferItem)
      error: (errorData) ->
        errorHandler(errorData)

  destroy: (successHandler, errorHandler) ->
    Spree.ajax
      url: Spree.routes.update_transfer_items_api(@stockTransferNumber, @id)
      type: "DELETE"
      success: (transferItem) ->
        successHandler(transferItem)
      error: (errorData) ->
        errorHandler(errorData)

Spree.TransferItem = TransferItem
