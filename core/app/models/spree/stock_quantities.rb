# frozen_string_literal: true

module Solidus
  # A value object to hold a map of variants to their quantities
  class StockQuantities
    attr_reader :quantities
    include Enumerable

    # @param quantities [Hash<Solidus::Variant=>Numeric>]
    def initialize(quantities = {})
      raise ArgumentError unless quantities.keys.all?{ |v| v.is_a?(Solidus::Variant) }
      raise ArgumentError unless quantities.values.all?{ |v| v.is_a?(Numeric) }

      @quantities = quantities
    end

    # @yield [variant, quantity]
    def each(&block)
      @quantities.each(&block)
    end

    # @param variant [Solidus::Variant]
    # @return [Integer] the quantity of variant
    def [](variant)
      @quantities[variant]
    end

    # @return [Array<Solidus::Variant>] the variants being tracked
    def variants
      @quantities.keys.uniq
    end

    # Adds two StockQuantities together
    # @return [Solidus::StockQuantities]
    def +(other)
      combine_with(other) do |_variant, a, b|
        (a || 0) + (b || 0)
      end
    end

    # Subtracts another StockQuantities from this one
    # @return [Solidus::StockQuantities]
    def -(other)
      combine_with(other) do |_variant, a, b|
        (a || 0) - (b || 0)
      end
    end

    # Finds the intersection or common subset of two StockQuantities: the
    # stock which exists in both StockQuantities.
    # @return [Solidus::StockQuantities]
    def &(other)
      combine_with(other) do |_variant, a, b|
        next unless a && b
        [a, b].min
      end
    end

    # A StockQuantities is empty if all variants have zero quantity
    # @return [true,false]
    def empty?
      @quantities.values.all?(&:zero?)
    end

    def ==(other)
      self.class == other.class &&
        quantities == other.quantities
    end

    protected

    def combine_with(other)
      self.class.new(
        (variants | other.variants).map do |variant|
          a = self[variant]
          b = other[variant]
          value = yield variant, a, b
          [variant, value]
        end.to_h.compact
      )
    end
  end
end
