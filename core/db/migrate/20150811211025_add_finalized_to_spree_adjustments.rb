class AddFinalizedToSpreeAdjustments < ActiveRecord::Migration
  # This migration replaces the open/closed state column of spree_adjustments
  # with a finalized boolean.
  # This may cause a few minutes of downtime on very large stores as the
  # adjustments table can become quite large.
  def change
    add_column :spree_adjustments, :finalized, :boolean
    execute "UPDATE spree_adjustments SET finalized=('closed' = state)"
    remove_column :spree_adjustments, :state, :string
  end
end
