# frozen_string_literal: true

class AddDefaultStateToInventoryUnit < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:spree_inventory_units, :state, 'on_hand')
  end
end
