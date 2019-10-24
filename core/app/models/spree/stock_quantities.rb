# frozen_string_literal: true

module Spree
  # A value object to hold a map of variants to their quantities
  class StockQuantities
    attr_reader :quantities
    include Enumerable

    # @param quantities [Hash<Spree::Variant=>Numeric>]
    def initialize(quantities = {})
      raise ArgumentError unless quantities.keys.all?{ |value| value.is_a?(Spree::Variant) }
      raise ArgumentError unless quantities.values.all?{ |value| value.is_a?(Numeric) }

      @quantities = quantities
    end

    # @yield [variant, quantity]
    def each(&block)
      @quantities.each(&block)
    end

    # @param variant [Spree::Variant]
    # @return [Integer] the quantity of variant
    def [](variant)
      @quantities[variant]
    end

    # @return [Array<Spree::Variant>] the variants being tracked
    def variants
      @quantities.keys.uniq
    end

    # Adds two StockQuantities together
    # @return [Spree::StockQuantities]
    def +(other)
      combine_with(other) do |_variant, first, second|
        (first || 0) + (second || 0)
      end
    end

    # Subtracts another StockQuantities from this one
    # @return [Spree::StockQuantities]
    def -(other)
      combine_with(other) do |_variant, first, second|
        (first || 0) - (second || 0)
      end
    end

    # Finds the intersection or common subset of two StockQuantities: the
    # stock which exists in both StockQuantities.
    # @return [Spree::StockQuantities]
    def &(other)
      combine_with(other) do |_variant, first, second|
        next unless first && second

        [first, second].min
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
          self_v = self[variant]
          other_v = other[variant]
          value = yield variant, self_v, other_v
          [variant, value]
        end.to_h.compact
      )
    end
  end
end
