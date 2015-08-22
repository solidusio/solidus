class AddFinalizedToSpreeAdjustments < ActiveRecord::Migration
  def change
    add_column :spree_adjustments, :finalized, :boolean
    execute %q(UPDATE spree_adjustments SET finalized=('open' = state))
    remove_column :spree_adjustments, :state, :string
  end
end
