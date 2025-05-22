module Spree
  class ManipulativeQueryMonitor
    def self.call(&block)
      counter = DBQueryMatchers::QueryCounter.new({matches: [/^\ *(INSERT|UPDATE|DELETE\ FROM)/]})
      ActiveSupport::Notifications.subscribed(counter.to_proc,
                                              "sql.active_record",
                                              &block)
      if counter.count > 0
        Rails.logger.warn("Detected #{counter.count} manipulative queries. #{counter.log.join(', ')}")
      end
    end
  end
end
