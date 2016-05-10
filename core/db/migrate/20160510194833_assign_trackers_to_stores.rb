class AssignTrackersToStores < ActiveRecord::Migration
  class Tracker < ActiveRecord::Base
    self.table_name = "spree_trackers"
    belongs_to :store
  end

  class Store < ActiveRecord::Base
    self.table_name = "spree_stores"
  end

  def up
    default_store = Store.find_by(default: true)

    unless default_store.nil? || Tracker.find_by(store_id: default_store.id)
      say_with_time "assigning active tracker to default store" do
        tracker = Tracker.find_by(active: true, store_id: nil)
        tracker.update!(store: default_store) if tracker
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
