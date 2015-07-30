module Spree
  class Tracker < Spree::Base
    def self.current
      tracker = find_by(active: true)
      tracker if tracker && tracker.analytics_id.present?
    end
  end
end
