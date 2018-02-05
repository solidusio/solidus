Spree.ready ->
  $('.js-edit-stock-item').each ->
    $el = $(this)
    model = new Spree.Models.StockItem($el.data('stock-item'))
    new Spree.Views.Stock.EditStockItemRow
      el: $el
      stockLocationName: $el.data('stock-location-name')
      model: model
