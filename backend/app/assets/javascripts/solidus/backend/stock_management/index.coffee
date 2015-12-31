$(document).ready ->
  return unless $('#listing_product_stock').length > 0
  Solidus.StockManagement.IndexAddForms.beginListening()
  Solidus.StockManagement.IndexUpdateForms.beginListening()
