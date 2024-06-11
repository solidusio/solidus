# frozen_string_literal: true

module Spree
  class DeprecatedConfigurableClass
    def self.new(*_args, &_block)
      @deprecation_proxy ||= DeprecationProxy.new
    end

    def self.method_missing(method_name, *args, &block)
      @deprecation_proxy ||= DeprecationProxy.new
      @deprecation_proxy.send(method_name, args, block)
    end

    def self.respond_to_missing?(_method_name, _include_private = false)
      true
    end

    class DeprecationProxy
      def method_missing(_method_name, *_args, &_block)
        issue_deprecation_warning
        self
      end

      def respond_to_missing?(_method_name, _include_private = false)
        true
      end

      private

      def issue_deprecation_warning
        Spree.deprecator.warn(
          <<-WARNING
            It appears you are using Solidus' Legacy promotion system. This system has been extracted into the
            `solidus_legacy_promotions` gem. Please add the gem to your Gemfile and follow in the instructions in the README.
          WARNING
        )
      end
    end
  end
end
