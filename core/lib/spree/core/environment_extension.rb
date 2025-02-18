# frozen_string_literal: true

require "spree/core/class_constantizer"
require "spree/core/nested_class_set"

module Spree
  module Core
    module EnvironmentExtension
      extend ActiveSupport::Concern

      class_methods do
        def add_class_set(name, default: [])
          define_method(name) do
            set = instance_variable_get(:"@#{name}")
            set ||= send(:"#{name}=", default)
            set
          end

          define_method(:"#{name}=") do |klasses|
            set = ClassConstantizer::Set.new
            set.concat(klasses)
            instance_variable_set(:"@#{name}", set)
          end
        end

        def add_nested_class_set(name, default: {})
          define_method(name) do
            set = instance_variable_get(:"@#{name}")
            set ||= send(:"#{name}=", default)
            set
          end

          define_method(:"#{name}=") do |hash|
            set = Spree::Core::NestedClassSet.new(hash)
            instance_variable_set(:"@#{name}", set)
          end
        end
      end
    end
  end
end
