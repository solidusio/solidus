Spree.ready ->
  $('.js-edit-stock-item').each ->
    $el = $(this)
    model = new Spree.StockItem($el.data('stock-item'))
    new Spree.Views.StockItem
      el: $el
      stockLocationName: $el.data('stock-location-name')
      model: model
