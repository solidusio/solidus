class AddFinalizedToSpreeAdjustments < ActiveRecord::Migration
  # This migration replaces the open/closed state column of solidus_adjustments
  # with a finalized boolean.
  # This may cause a few minutes of downtime on very large stores as the
  # adjustments table can become quite large.
  def change
    add_column :solidus_adjustments, :finalized, :boolean
    execute %q(UPDATE solidus_adjustments SET finalized=('closed' = state))
    remove_column :solidus_adjustments, :state, :string
  end
end
