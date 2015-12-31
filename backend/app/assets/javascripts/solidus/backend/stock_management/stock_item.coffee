class StockItem
  constructor: (options = {}) ->
    @id = options.id
    @variantId = options.variantId
    @backorderable = options.backorderable
    @countOnHand = options.countOnHand
    @stockLocationId = options.stockLocationId

  save: (successHandler, errorHandler) ->
    Solidus.ajax
      url: Solidus.routes.stock_items_api(@stockLocationId)
      type: "POST"
      data:
        stock_item:
          variant_id: @variantId
          backorderable: @backorderable
          count_on_hand: @countOnHand
      success: (stockItem) ->
        successHandler(stockItem)
      error: (errorData) ->
        errorHandler(errorData)

  update: (successHandler, errorHandler) ->
    Solidus.ajax
      url: "#{Solidus.routes.stock_items_api(@stockLocationId)}/#{@id}"
      type: "PUT"
      data:
        stock_item:
          backorderable: @backorderable
          count_on_hand: @countOnHand
          force: true
      success: (stockItem) ->
        successHandler(stockItem)
      error: (errorData) ->
        errorHandler(errorData)

Solidus.StockItem = StockItem
