# frozen_string_literal: true

module Spree
  # Base class for all types of promotion action.
  #
  # PromotionActions perform the necessary tasks when a promotion is activated
  # by an event and determined to be eligible.
  class PromotionAction < Spree::Base
    include Spree::SoftDeletable

    belongs_to :promotion, class_name: 'Spree::Promotion', inverse_of: :promotion_actions, optional: true

    scope :of_type, ->(type) { where(type: Array.wrap(type).map(&:to_s)) }
    scope :shipping, -> { of_type(Spree::Config.environment.promotions.shipping_actions.to_a) }

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
    # @note This method should be overriden in subclassses.
    #
    # @param order [Spree::Order] the order to remove the action from
    # @return [void]
    def remove_from(order)
      Spree::Deprecation.warn("#{self.class.name.inspect} does not define #remove_from. The default behavior may be incorrect and will be removed in a future version of Solidus.", caller)
      [order, *order.line_items, *order.shipments].each do |item|
        item.adjustments.each do |adjustment|
          if adjustment.source == self
            item.adjustments.destroy(adjustment)
          end
        end
      end
    end

    def to_partial_path
      "spree/admin/promotions/actions/#{model_name.element}"
    end
  end
end
