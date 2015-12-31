class AddIncludedToAdjustments < ActiveRecord::Migration
  def change
    add_column :spree_adjustments, :included, :boolean, :default => false unless Solidus::Adjustment.column_names.include?("included")
  end
end
