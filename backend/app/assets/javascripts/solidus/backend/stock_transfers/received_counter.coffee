class ReceivedCounter
  @updateTotal: ->
    newTotal = _.reduce($('.js-number-update-text'), (memo, el) ->
      memo + parseInt($(el).text().trim(), 10)
    , 0)
    $('#total-received-quantity').text(newTotal)

Solidus.StockTransfers ?= {}
Solidus.StockTransfers.ReceivedCounter = ReceivedCounter
