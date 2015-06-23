class StockTransfer
  constructor: (options = {}) ->
    @number = options.number
    @transferItems = options.transferItems

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
