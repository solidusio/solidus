class ReceivedCounter
  @updateTotal: ->
    newTotal = _.reduce($('.js-received-count-text'), (memo, el) ->
      memo + parseInt($(el).text().trim(), 10)
    , 0)
    $('#total-received-quantity').text(newTotal)

Spree.StockTransfers ?= {}
Spree.StockTransfers.ReceivedCounter = ReceivedCounter
