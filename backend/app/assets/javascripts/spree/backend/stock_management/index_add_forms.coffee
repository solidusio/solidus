Spree.ready ->
  $('.js-add-stock-item').each ->
    $el = $(this)
    model = new Spree.Models.StockItem
      variant_id: $el.data('variant-id')
    new Spree.Views.Stock.AddStockItem
      el: $el
      model: model
