class RenameAdjustmentFields < ActiveRecord::Migration
  def up
    remove_column :solidus_adjustments, :originator_id
    remove_column :solidus_adjustments, :originator_type

    add_column :solidus_adjustments, :order_id, :integer unless column_exists?(:solidus_adjustments, :order_id)

    # This enables the Solidus::Order#all_adjustments association to work correctly
    Solidus::Adjustment.reset_column_information
    Solidus::Adjustment.where(adjustable_type: "Solidus::Order").find_each do |adjustment|
      adjustment.update_column(:order_id, adjustment.adjustable_id)
    end
  end
end
