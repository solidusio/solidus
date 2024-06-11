# frozen_string_literal: true

require "spree/core/class_constantizer"

module Spree
  module Core
    class NestedClassSet
      attr_reader :klass_sets

      def initialize(hash = {})
        @klass_sets = hash.map do |key, value|
          [
            key.to_s,
            ClassConstantizer::Set.new(default: value)
          ]
        end.to_h
      end

      def [](klass)
        klass_sets[klass.to_s] || []
      end

      def []=(klass, klasses)
        klass_sets[klass.to_s] = ClassConstantizer::Set.new(default: klasses.map(&:to_s))
      end
    end
  end
end
