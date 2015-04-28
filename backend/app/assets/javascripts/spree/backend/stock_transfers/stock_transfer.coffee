class StockTransfer
  constructor: (options = {}) ->
    @number = options.number
    @transferItems = options.transferItems

  findTransferItemByVariantId: (variantId) ->
    _.find(@transferItems, (transferItem) =>
      transferItem.variant.id is variantId
    )

  receive: (variantId, successHandler, errorHandler) ->
    Spree.ajax
      url: Spree.routes.receive_stock_transfer_api(@number)
      type: "POST"
      data:
        variant_id: variantId
      success: (stockTransfer) =>
        successHandler(stockTransfer, variantId)
      error: (errorData) ->
        errorHandler(errorData)

Spree.StockTransfer = StockTransfer
