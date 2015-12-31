class UpdateShipmentStateForCanceledOrders < ActiveRecord::Migration
  def up
    shipments = Solidus::Shipment.joins(:order).
      where("solidus_orders.state = 'canceled'")
    case Solidus::Shipment.connection.adapter_name
    when "SQLite3"
      shipments.update_all("state = 'cancelled'")
    when "MySQL" || "PostgreSQL"
      shipments.update_all("solidus_shipments.state = 'cancelled'")
    end
  end

  def down
  end
end
