class RemoveMandatoryFromAdjustments < ActiveRecord::Migration[4.2]
  def change
    remove_column :spree_adjustments, :mandatory, :boolean
  end
end
