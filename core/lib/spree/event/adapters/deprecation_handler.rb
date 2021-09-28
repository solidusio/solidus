# frozen_string_literal: true

require 'spree/event/adapters/active_support_notifications'
require 'spree/deprecation'

module Spree
  module Event
    module Adapters
      # @api private
      module DeprecationHandler
        LEGACY_ADAPTER = ActiveSupportNotifications

        CI_LEGACY_ADAPTER_ENV_KEY = 'CI_LEGACY_EVENT_BUS_ADAPTER'

        def self.legacy_adapter?(adapter)
          adapter == LEGACY_ADAPTER
        end

        def self.legacy_adapter_set_by_env
          return LEGACY_ADAPTER if ENV[CI_LEGACY_ADAPTER_ENV_KEY].present?
        end

        def self.render_deprecation_message?(adapter)
          legacy_adapter?(adapter) && legacy_adapter_set_by_env.nil?
        end
      end
    end
  end
end
