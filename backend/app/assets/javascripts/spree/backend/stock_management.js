Spree.ready(function() {
  $('.js-edit-stock-item').each(function() {
    var $el = $(this);
    var model = new Spree.Models.StockItem($el.data('stock-item'));
    var trackInventory = $el.data('track-inventory');
    new Spree.Views.Stock.EditStockItemRow({
      el: $el,
      stockLocationName: $el.data('stock-location-name'),
      model: model
    });

    if (trackInventory === false) {
      $('.js-edit-stock-item input').attr({
        disabled: true,
        class: 'with-tip',
        title: '"Track inventory" option disabled for this variant'
      });
    }
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
