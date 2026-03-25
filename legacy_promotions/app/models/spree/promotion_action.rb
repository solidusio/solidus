# frozen_string_literal: true

module Spree
  # Base class for all types of promotion action.
  #
  # PromotionActions perform the necessary tasks when a promotion is activated
  # by an event and determined to be eligible.
  class PromotionAction < Spree::Base
    include Spree::Preferences::Persistable
    include Spree::SoftDeletable

    belongs_to :promotion, class_name: "Spree::Promotion", inverse_of: :promotion_actions, optional: true

    scope :of_type, ->(type) { where(type: Array.wrap(type).map(&:to_s)) }
    scope :shipping, -> { of_type(Spree::Config.promotions.shipping_actions.to_a) }

    def preload_relations
      []
    end

    # Updates the state of the order or performs some other action depending on
    # the subclass options will contain the payload from the event that
    # activated the promotion. This will include the key :user which allows
    # user based actions to be performed in addition to actions on the order
    #
    # @note This method should be overriden in subclassses.
    def perform(_options = {})
      raise "perform should be implemented in a sub-class of PromotionAction"
    end

    # Removes the action from an order
    #
    # @note This method should be overriden in subclassses.
    #
    # @param order [Spree::Order] the order to remove the action from
    # @return [void]
    def remove_from(_order)
      raise "remove_from should be implemented in a sub-class of PromotionAction"
    end

    def to_partial_path
      "spree/admin/promotions/actions/#{model_name.element}"
    end

    def available_calculators
      Spree::Config.promotions.calculators[self.class]
    end
  end
end
