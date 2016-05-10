module Spree
  class Tracker < Spree::Base
    belongs_to :store

    def self.current(store = nil)
      tracker =
        if store
          find_by(active: true, store_id: store.id)
        else
          ActiveSupport::Deprecation.warn <<-EOS.squish, caller
            Calling Spree::Tracker.current without a store is DEPRECATED.
            Instead, please provide a Spree::Store.
          EOS
          find_by(active: true)
        end

      tracker.try(:analytics_id).blank? ? nil : tracker
    end
  end
end
