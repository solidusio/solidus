# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module SpreeConstant
      def self.activate
        Spree.module_eval do
          def self.const_missing(missing_const_name)
            solidus_constant = ActiveSupport::Inflector.safe_constantize("Solidus::#{missing_const_name}")
            puts "#{missing_const_name} resolves to #{solidus_constant.inspect}"
            solidus_constant || super
          end
        end
      end
    end
  end
end
