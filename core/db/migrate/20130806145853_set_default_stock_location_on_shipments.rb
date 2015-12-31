class SetDefaultStockLocationOnShipments < ActiveRecord::Migration
  def change
    if Solidus::Shipment.where('stock_location_id IS NULL').count > 0
      location = Solidus::StockLocation.find_by(name: 'default') || Solidus::StockLocation.first
      Solidus::Shipment.where('stock_location_id IS NULL').update_all(stock_location_id: location.id)
    end
  end
end
