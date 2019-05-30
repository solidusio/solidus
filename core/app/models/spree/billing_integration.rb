# frozen_string_literal: true

module Spree
  class BillingIntegration < PaymentMethod
    validates :name, presence: true

    preference :server, :string, default: 'test'
    preference :test_mode, :boolean, default: true

    def gateway
      integration_options = options

      # All environments except production considered to be test
      test_server = integration_options[:server] != 'production'
      test_mode = integration_options[:test_mode]

      integration_options[:test] = (test_server || test_mode)

      @gateway ||= gateway_class.new(integration_options)
    end

    def options
      options_hash = {}
      preferences.each { |key, value| options_hash[key.to_sym] = value }
      options_hash
    end
  end
end
