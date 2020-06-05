Spree.ready(function() {
  var $stockLocationsSelect = $('#shipping_method_stock_location_ids'),
      $availableToAllCheckbox = $('#shipping_method_available_to_all');

  if ($stockLocationsSelect.length === 0 || $availableToAllCheckbox.length === 0) {
    return;
  }

  function toggleLocationSelectVisibility() {
    $stockLocationsSelect.toggleClass('hidden', $availableToAllCheckbox[0].checked);
  }

  $availableToAllCheckbox.on('click', function() {
    toggleLocationSelectVisibility();
  });

  toggleLocationSelectVisibility();
})
