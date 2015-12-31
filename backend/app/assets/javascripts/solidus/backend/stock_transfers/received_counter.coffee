class ReceivedCounter
  @updateTotal: ->
    newTotal = _.reduce($('.js-number-update-text'), (memo, el) ->
      memo + parseInt($(el).text().trim(), 10)
    , 0)
    $('#total-received-quantity').text(newTotal)

Spree.StockTransfers ?= {}
Spree.StockTransfers.ReceivedCounter = ReceivedCounter
