# frozen_string_literal: true

class AddMetadataToSpreeResources < ActiveRecord::Migration[7.2]
  def change
    # List of Resources to add metadata columns to
    %i[
      spree_orders
      spree_line_items
      spree_shipments
      spree_payments
      spree_refunds
      spree_customer_returns
      spree_store_credit_events
      spree_users
      spree_return_authorizations
    ].each do |table_name|
      change_table table_name do |t|
        # Check if the database supports jsonb for efficient querying
        if t.respond_to?(:jsonb)
          add_column table_name, :customer_metadata, :jsonb, default: {}
          add_column table_name, :admin_metadata, :jsonb, default: {}
        else
          add_column table_name, :customer_metadata, :json
          add_column table_name, :admin_metadata, :json
        end
      end
    end
  end
end
