# frozen_string_literal: true

module Spree
  class Calculator < Spree::Base
    include Spree::Preferences::Persistable

    belongs_to :calculable, polymorphic: true, optional: true

    # Computes an amount based on the calculable and the computable parameter.
    #
    # This method dynamically calls a compute_<computable> method based on the class
    # of the computable parameter. Concrete calculator classes must implement the
    # appropriate compute method for each computable type they support.
    #
    # For example, if the computable is a Spree::LineItem, this will call
    # compute_line_item(computable, ...). If the computable is a Spree::Order,
    # it will call compute_order(computable, ...).
    #
    # @param computable [Object] The object to compute the amount for (e.g.,
    #                            Spree::LineItem, Spree::Order, Spree::Shipment,
    #                            Spree::ShippingRate)
    # @param ... [args, kwargs] Additional arguments passed to the specific compute method
    #
    # @return [BigDecimal, Numeric] The computed amount
    #
    # @raise [NotImplementedError] If the calculator doesn't implement the required compute method
    #
    # @example Implementing a calculator for line items
    #   class MyCalculator < Spree::Calculator
    #     def compute_line_item(line_item)
    #       line_item.amount * 0.1 # 10% of line item amount
    #     end
    #   end
    #
    # @see Spree::CalculatedAdjustments for how calculators connect to calculables, such as
    #      Spree::TaxRate, Spree::ShippingRate, SolidusPromotions::Benefit, or Spree::PromotionAction
    def compute(computable, ...)
      # Spree::LineItem -> :compute_line_item
      computable_name = computable.class.name.demodulize.underscore
      method_name = :"compute_#{computable_name}"
      calculator_class = self.class
      if respond_to?(method_name)
        send(method_name, computable, ...)
      else
        raise NotImplementedError, "Please implement '#{method_name}(#{computable_name})' in your calculator: #{calculator_class.name}"
      end
    end

    # A description for this calculator in few words
    # @return [String] A description for the calculator
    def self.description
      model_name.human
    end

    ###################################################################

    def to_s
      self.class.name.titleize.gsub("Calculator\/", "")
    end

    def description
      self.class.description
    end

    def available?(_object)
      true
    end
  end
end
