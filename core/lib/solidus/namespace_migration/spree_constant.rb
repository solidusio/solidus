# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module SpreeConstant
      def self.activate
        Object.const_set('Spree', ActiveSupport::Deprecation::DeprecatedConstantProxy.new('Spree', 'Solidus'))
      end
    end
  end
end
