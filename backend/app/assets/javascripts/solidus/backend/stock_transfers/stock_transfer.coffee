class StockTransfer
  constructor: (options = {}) ->
    @number = options.number
    @transferItems = options.transferItems

  receive: (variantId, successHandler, errorHandler) ->
    Solidus.ajax
      url: Solidus.routes.receive_stock_transfer_api(@number)
      type: "POST"
      data:
        variant_id: variantId
      success: (stockTransfer) =>
        successHandler(stockTransfer, variantId)
      error: (errorData) ->
        errorHandler(errorData)

Solidus.StockTransfer = StockTransfer
