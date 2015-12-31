class AddIndexToSourceColumnsOnAdjustments < ActiveRecord::Migration
  def change
    add_index :solidus_adjustments, [:source_type, :source_id]
  end
end
