class RemoveMandatoryFromAdjustments < ActiveRecord::Migration
  def change
    remove_column :spree_adjustments, :mandatory, :boolean
  end
end
