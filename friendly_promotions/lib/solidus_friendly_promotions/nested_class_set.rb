# frozen_string_literal: true

require "spree/core/class_constantizer"

module SolidusFriendlyPromotions
  class NestedClassSet
    attr_reader :klass_sets

    def initialize(hash = {})
      @klass_sets = hash.map do |key, value|
        [
          key,
          Spree::Core::ClassConstantizer::Set.new.tap do |set|
            value.each { |klass_name| set << klass_name }
          end
        ]
      end.to_h
    end

    def [](klass)
      klass_sets[klass.name]
    end
  end
end
