# frozen_string_literal: true

module Spree
  class ManipulativeQueryMonitor
    MANIPULATIVE_QUERY = /^\ *(INSERT|UPDATE|DELETE\ FROM)/

    def self.call(&block)
      queries = []
      callback = ->(*, payload) { queries << payload[:sql].strip if payload[:sql].match?(MANIPULATIVE_QUERY) }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &block)

      if queries.any?
        message = "Detected #{queries.count} manipulative queries. #{queries.join(", ")}\n"

        message += caller.select { |line| line.include?(Rails.root.to_s) || line.include?("solidus") }.join("\n")

        Rails.logger.warn(message)
      end
    end
  end
end
