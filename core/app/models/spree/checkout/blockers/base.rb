module Spree::Checkout::Blockers
  # Abstract base class for single validation. Provides some helper methods for
  # implement the CheckoutBlockers
  #
  # @author Marino Bonetti
  # @abstract
  # @attr [Spree::Order] order the order model to validate the transition to checkout
  class Base

    attr_accessor :order

    def initialize(order)
      @order=order
    end


    # Method to implement in Custom Validators Blocks
    #
    # @abstract
    #
    # @return [TrueClass,FalseClass] true or false respect the validation
    #
    def blocks_checkout?
      raise 'Override in custom validation blocks'
    end

  end
end
