# frozen_string_literal: true

module Spree
  class ShippingCalculator < Calculator
    def compute_package(_package)
      raise NotImplementedError, "Please implement 'compute_package(package)' in your calculator: #{self.class.name}"
    end

    def available?(_package)
      true
    end

    private

    def total(content_items)
      content_items.map(&:amount).sum
    end
  end
end
