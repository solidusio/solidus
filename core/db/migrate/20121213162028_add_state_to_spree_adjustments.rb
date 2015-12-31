class AddStateToSpreeAdjustments < ActiveRecord::Migration
  def change
    add_column :solidus_adjustments, :state, :string
    remove_column :solidus_adjustments, :locked
  end
end
