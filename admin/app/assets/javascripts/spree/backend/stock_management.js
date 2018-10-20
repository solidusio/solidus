Spree.ready(function() {
  $('.js-edit-stock-item').each(function() {
    var $el = $(this);
    var model = new Spree.Models.StockItem($el.data('stock-item'));
    new Spree.Views.Stock.EditStockItemRow({
      el: $el,
      stockLocationName: $el.data('stock-location-name'),
      model: model
    });
  });

  $('.js-add-stock-item').each(function() {
    var $el = $(this)
    var model = new Spree.Models.StockItem({
      variant_id: $el.data('variant-id')
    });
    new Spree.Views.Stock.AddStockItem({
      el: $el,
      model: model
    });
  });
});
