module Spree
  # Base class for all types of promotion action.
  #
  # PromotionActions perform the necessary tasks when a promotion is activated
  # by an event and determined to be eligible.
  class PromotionAction < Spree::Base
    acts_as_paranoid

    belongs_to :promotion, class_name: 'Spree::Promotion'

    scope :of_type, ->(t) { where(type: t) }

    # Updates the state of the order or performs some other action depending on
    # the subclass options will contain the payload from the event that
    # activated the promotion. This will include the key :user which allows
    # user based actions to be performed in addition to actions on the order
    #
    # @note This method should be overriden in subclassses.
    def perform(_options = {})
      raise 'perform should be implemented in a sub-class of PromotionAction'
    end

    # Removes the action from an order
    #
    # @note A PromotionAction subclass should override this method if it does
    # something other than add adjustments.
    #
    # @param order [Spree::Order] the order to remove the action from
    # @return [undefined]
    def remove_from(order)
      [order, *order.line_items, *order.shipments].each do |item|
        item.adjustments.each do |adjustment|
          if adjustment.source == self
            item.adjustments.destroy(adjustment)
          end
        end
      end
    end
  end
end
