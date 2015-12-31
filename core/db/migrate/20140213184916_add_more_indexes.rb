class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index :solidus_payment_methods, [:id, :type]
    add_index :solidus_calculators, [:id, :type]
    add_index :solidus_calculators, [:calculable_id, :calculable_type]
    add_index :solidus_payments, :payment_method_id
    add_index :solidus_promotion_actions, [:id, :type]
    add_index :solidus_promotion_actions, :promotion_id
    add_index :solidus_promotions, [:id, :type]
    add_index :solidus_option_values, :option_type_id
    add_index :solidus_shipments, :stock_location_id
  end
end
