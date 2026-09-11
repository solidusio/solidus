# frozen_string_literal: true

class RenameStockLocationStateToPrincipalSubdivision < ActiveRecord::Migration[7.2]
  def change
    rename_column :spree_stock_locations, :state_id, :principal_subdivision_id
    rename_column :spree_stock_locations, :state_name, :principal_subdivision_name
  end
end
