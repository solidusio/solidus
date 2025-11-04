# frozen_string_literal: true

module SolidusPromotions
  # Base class for all promotion conditions.
  #
  # Conditions determine whether a promotion is eligible to be applied to a specific
  # promotable object (such as an order or line item). Each condition subclass implements
  # the eligibility logic and specifies what type of objects it can be applied to.
  #
  # Conditions work at different levels:
  # - Order-level conditions (include OrderLevelCondition): Check entire orders
  # - Line item-level conditions (include LineItemLevelCondition): Check individual line items
  # - Hybrid conditions (include LineItemApplicableOrderLevelCondition): Check orders but can also
  #   filter which line items are eligible
  #
  # @abstract Subclass and override {#applicable?} and {#eligible?} to implement
  #   a custom condition.
  #
  # @example Creating an order-level condition
  #   class MinimumPurchaseCondition < Condition
  #     include OrderLevelCondition
  #
  #     preference :minimum_amount, :decimal, default: 50.00
  #
  #     def eligible?(order, _options = {})
  #       if order.item_total < preferred_minimum_amount
  #         eligibility_errors.add(:base, "Order total too low")
  #       end
  #       eligibility_errors.empty?
  #     end
  #   end
  #
  # @example Creating a line item-level condition
  #   class SpecificProductCondition < Condition
  #     include LineItemLevelCondition
  #
  #     preference :product_id, :integer
  #
  #     def eligible?(line_item, _options = {})
  #       if line_item.product_id != preferred_product_id
  #         eligibility_errors.add(:base, "Wrong product")
  #       end
  #       eligibility_errors.empty?
  #     end
  #   end
  class Condition < Spree::Base
    include Spree::Preferences::Persistable

    belongs_to :benefit, class_name: "SolidusPromotions::Benefit", inverse_of: :conditions
    has_one :promotion, through: :benefit

    scope :of_type, ->(type) { where(type: type) }

    validate :unique_per_benefit, on: :create
    validate :possible_condition_for_benefit, if: -> { benefit.present? }

    # Returns relations that should be preloaded for this condition.
    #
    # Override this method in subclasses to specify associations that should be eager loaded
    # to avoid N+1 queries when evaluating conditions.
    #
    # @return [Array<Symbol>] An array of association names to preload
    #
    # @example Preloading products association
    #   def preload_relations
    #     [:products]
    #   end
    def preload_relations
      []
    end

    # Determines if this condition can be applied to a given promotable object.
    #
    # This method is typically implemented by including one of the level modules
    # (OrderLevelCondition, LineItemLevelCondition, or LineItemApplicableOrderLevelCondition)
    # rather than being overridden directly.
    #
    # @param _promotable [Object] The object to check (e.g., Spree::Order, Spree::LineItem)
    #
    # @return [Boolean] true if this condition applies to the promotable type
    #
    # @raise [NotImplementedError] if not implemented in subclass
    #
    # @example Order-level condition applicability
    #   condition.applicable?(order)      # => true
    #   condition.applicable?(line_item)  # => false
    #
    # @see OrderLevelCondition
    # @see LineItemLevelCondition
    # @see LineItemApplicableOrderLevelCondition
    def applicable?(_promotable)
      raise NotImplementedError, "applicable? should be implemented in a sub-class of SolidusPromotions::Condition"
    end

    # Determines if the promotable object meets this condition's eligibility requirements.
    #
    # This is the core method that implements the condition's logic. When the promotable
    # is not eligible, this method should add errors to {#eligibility_errors} explaining why.
    #
    # @param _promotable [Object] The object to evaluate (e.g., Spree::Order, Spree::LineItem)
    # @param _options [Hash] Additional options for eligibility checking
    #
    # @return [Boolean] true if the promotable meets the condition, false otherwise
    #
    # @raise [NotImplementedError] if not implemented in subclass
    #
    # @example Order total condition
    #   def eligible?(order, _options = {})
    #     if order.item_total < preferred_minimum
    #       eligibility_errors.add(:base, "Order total too low")
    #     end
    #     eligibility_errors.empty?
    #   end
    #
    # @example First order condition
    #   def eligible?(order, _options = {})
    #     if order.user.orders.complete.count > 1
    #       eligibility_errors.add(:base, "Not first order")
    #     end
    #     eligibility_errors.empty?
    #   end
    #
    # @see #eligibility_errors
    def eligible?(_promotable, _options = {})
      raise NotImplementedError, "eligible? should be implemented in a sub-class of SolidusPromotions::Condition"
    end

    def level
      raise NotImplementedError, "level should be implemented in a sub-class of SolidusPromotions::Condition"
    end

    # Returns an errors object for tracking eligibility failures.
    #
    # When {#eligible?} determines that a promotable doesn't meet the condition,
    # it should add descriptive errors to this object. These errors are used to
    # provide feedback about why a promotion isn't being applied.
    #
    # @return [ActiveModel::Errors] An errors collection for this condition
    #
    # @example Adding an eligibility error
    #   def eligible?(order, _options = {})
    #     if order.item_total < 50
    #       eligibility_errors.add(:base, "Minimum order is $50", error_code: :item_total_too_low)
    #     end
    #     eligibility_errors.empty?
    #   end
    def eligibility_errors
      @eligibility_errors ||= ActiveModel::Errors.new(self)
    end

    # Returns the partial path for rendering this condition in the admin interface.
    #
    # @return [String] The path to the admin form partial for this condition
    #
    # @example
    #   # For SolidusPromotions::Conditions::ItemTotal
    #   # => "solidus_promotions/admin/condition_fields/item_total"
    def to_partial_path
      "solidus_promotions/admin/condition_fields/#{model_name.element}"
    end

    # Determines if this condition can be updated in the admin interface.
    #
    # A condition is considered updateable if it has any preferences that can be configured.
    #
    # @return [Boolean] true if the condition has configurable preferences
    def updateable?
      preferences.any?
    end

    private

    # Validates that only one instance of this condition type exists per benefit.
    #
    # Prevents duplicate conditions of the same type from being added to a single benefit.
    def unique_per_benefit
      return unless self.class.exists?(benefit_id: benefit_id, type: self.class.name)

      errors.add(:benefit, :already_contains_condition_type)
    end

    # Validates that this condition type is allowed for the associated benefit.
    #
    # Checks the benefit's {Benefit#possible_conditions} to ensure this condition
    # type is compatible.
    def possible_condition_for_benefit
      benefit.possible_conditions.include?(self.class) || errors.add(:type, :invalid_condition_type)
    end

    # Generates a translated eligibility error message.
    #
    # Looks up the error message in the I18n translations under the condition's scope.
    #
    # @param key [Symbol] The I18n key for the error message
    # @param options [Hash] Interpolation options for the message
    #
    # @return [String] The translated error message
    #
    # @example
    #   eligibility_error_message(:item_total_too_low, minimum: "$50")
    def eligibility_error_message(key, options = {})
      I18n.t(key, scope: [:solidus_promotions, :eligibility_errors, self.class.name.underscore], **options)
    end
  end
end
