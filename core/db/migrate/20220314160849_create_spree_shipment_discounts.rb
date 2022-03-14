# frozen_string_literal: true

class CreateSpreeShipmentDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_shipment_discounts do |t|
      t.references :shipment, null: false
      t.references :promotion_action, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :label, null: false

      t.timestamps
    end
  end
end
