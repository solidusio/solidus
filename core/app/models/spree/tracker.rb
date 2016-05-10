module Spree
  class Tracker < Spree::Base
    belongs_to :store

    def self.current
      tracker = where(active: true).first
      tracker.analytics_id.present? ? tracker : nil if tracker
    end
  end
end
