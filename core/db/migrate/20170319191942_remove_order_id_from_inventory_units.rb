# frozen_string_literal: true

class RemoveOrderIdFromInventoryUnits < ActiveRecord::Migration[5.0]
  class InconsistentInventoryUnitError < StandardError; end

  class InventoryUnit < ActiveRecord::Base
    self.table_name = "spree_inventory_units"
    belongs_to :shipment
  end

  class Shipment < ActiveRecord::Base
    self.table_name = "spree_shipments"
    has_many :inventory_units
  end

  def up
    if InventoryUnit.
        joins(:shipment).
        where.not(
          'spree_inventory_units.order_id = spree_shipments.order_id'
        ).exists?
      raise InconsistentInventoryUnitError, "You have inventory units with inconsistent order references. Please fix those before running this migration"
    end
    remove_column :spree_inventory_units, :order_id
  end

  def down
    add_reference :spree_inventory_units, :order, index: true
  end
end
