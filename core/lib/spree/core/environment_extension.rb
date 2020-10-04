# frozen_string_literal: true

require 'spree/core/class_constantizer'

module Spree
  module Core
    module EnvironmentExtension
      extend ActiveSupport::Concern

      class_methods do
        def add_class_set(name)
          define_method(name) do
            set = instance_variable_get("@#{name}")
            set ||= send("#{name}=", [])
            set
          end

          define_method("#{name}=") do |klasses|
            set = ClassConstantizer::Set.new
            set.concat(klasses)
            instance_variable_set("@#{name}", set)
          end
        end
      end

      def add_class(name)
        Spree::Deprecation.warn(
          'This method is deprecated. ' \
          "Please use `#{self.class}.add_class_set(#{name.inspect})` instead.",
          caller,
        )
        singleton_class.send(:add_class_set, name)
      end
    end
  end
end
