class AddStoreIdToTrackers < ActiveRecord::Migration
  def change
    unless column_exists?(:spree_trackers, :store_id)
      add_column :spree_trackers, :store_id, :integer
    end
  end
end
