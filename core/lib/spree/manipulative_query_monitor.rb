# frozen_string_literal: true

module Spree
  class ManipulativeQueryMonitor
    def self.call(&block)
      counter = ::DBQueryMatchers::QueryCounter.new({matches: [/^\ *(INSERT|UPDATE|DELETE\ FROM)/]})
      ActiveSupport::Notifications.subscribed(counter.to_proc,
                                              "sql.active_record",
                                              &block)
      if counter.count > 0
        message = "Detected #{counter.count} manipulative queries. #{counter.log.join(', ')}\n"

        message += caller.select{ |line| line.include?(Rails.root.to_s) || line.include?('solidus') }.join("\n") }

        Rails.logger.warn(message)
      end
    end
  end
end
