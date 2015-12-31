module Spree
  class Tracker < Solidus::Base
    def self.current
      tracker = where(active: true).first
      tracker.analytics_id.present? ? tracker : nil if tracker
    end
  end
end
