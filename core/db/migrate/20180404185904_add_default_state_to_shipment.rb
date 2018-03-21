# frozen_string_literal: true

class AddDefaultStateToShipment < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:spree_shipments, :state, 'pending')
  end
end
