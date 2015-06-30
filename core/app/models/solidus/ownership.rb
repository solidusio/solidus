module Solidus
  # Solidus::Ownership is responsible for assigning rights to
  # an order
  class Ownership
    # @param [Solidus::Order] the order for which ownership is being assigned
    def initialize(order)
      @order = order
    end

    # Give complete ownership of the order to the given spree user
    # @param [Spree::User] The order to be granted sole ownership
    def associate_to_user user
      @order.lock do
        @order.model.user = user
        @order.model.save
      end
    end
  end
end
