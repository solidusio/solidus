class RemoveMandatoryFromAdjustments < ActiveRecord::Migration
  def change
    remove_column :solidus_adjustments, :mandatory, :boolean
  end
end
