$(document).ready ->
  return unless $('#listing_product_stock').length > 0
  Spree.StockManagement.IndexAddForms.beginListening()
  Spree.StockManagement.IndexUpdateForms.beginListening()
