# frozen_string_literal: true

class AddPublicAndPrivateMetadataToSpreeResources < ActiveRecord::Migration[7.0]
  def change
    # List of Resources to add metadata columns to
    %i[
      spree_orders
      spree_line_items
      spree_shipments
      spree_payments
      spree_stock_movements
      spree_addresses
      spree_refunds
    ].each do |table_name|
      change_table table_name do |t|
        # Check if the database supports jsonb for efficient querying
        if t.respond_to?(:jsonb)
          add_column table_name, :public_metadata, :jsonb, default: {}
          add_column table_name, :private_metadata, :jsonb, default: {}
        else
          add_column table_name, :public_metadata, :json, default: {}
          add_column table_name, :private_metadata, :json, default: {}
        end
      end
    end
  end
end
