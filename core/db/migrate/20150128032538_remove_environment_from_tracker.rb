class RemoveEnvironmentFromTracker < ActiveRecord::Migration
  def up
    Solidus::Tracker.where('environment != ?', Rails.env).update_all(active: false)
    remove_column :spree_trackers, :environment
  end
end
