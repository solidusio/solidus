# frozen_string_literal: true

module SolidusPromotions
  # Base class for all promotion conditions.
  #
  # Conditions determine whether a promotion is eligible to be applied to a specific
  # promotable object (such as an order or line item). Each condition subclass implements
  # the eligibility logic and specifies what type of objects it can be applied to.
  #
  # Conditions work at different levels, depending on the eligibility methods they define:
  # - Order-level conditions (define `order_eligible?`): Check entire orders
  # - Line item-level conditions (define `line_item_eligible?`): Check individual line items
  # - Hybrid conditions (define both): Check orders and also filter which line items are eligible
  #
  # @abstract Subclass and define a public `<type>_eligible?` method for each
  #   promotable class, e.g. `order_eligible?` for Spree::Order.
  #
  # @example Creating an order-level condition
  #   class MinimumPurchaseCondition < Condition
  #     preference :minimum_amount, :decimal, default: 50.00
  #
  #     def order_eligible?(order, _options = {})
  #       if order.item_total < preferred_minimum_amount
  #         eligibility_errors.add(:base, "Order total too low")
  #       end
  #       eligibility_errors.empty?
  #     end
  #   end
  #
  # @example Creating a line item-level condition
  #   class SpecificProductCondition < Condition
  #     preference :product_id, :integer
  #
  #     def line_item_eligible?(line_item, _options = {})
  #       if line_item.variant.product_id != preferred_product_id
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

    class << self
      # Returns the configured condition classes that can compute eligibility for instances of any of the provided classes.
      #
      # @example SolidusPromotions::Condition.applicable_to([Spree::Order, Spree::LineItem])
      #
      # @param classes [Array<Class>] An array of classes to compute eligibility for
      # @return [Array<Class<SolidusPromotions::Condition>>]
      def applicable_to(classes)
        SolidusPromotions.config.conditions.select do |condition_class|
          (condition_class.instance_methods & classes.map { |k| eligible_method_for(k) }).any?
        end
      end

      # Generates the eligibility method name for a promotable
      #
      # @return [Symbol] the method name
      def eligible_method_for(promotable_class)
        :"#{promotable_class.name.demodulize.underscore}_eligible?"
      end
    end

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
    # @param promotable [Object] The object to check (e.g., Spree::Order, Spree::LineItem)
    #
    # @return [Boolean] true if this condition applies to the promotable type
    #
    # @example A condition that only defines `order_eligible?`
    #   condition.applicable?(order)      # => true
    #   condition.applicable?(line_item)  # => false
    def applicable?(promotable)
      respond_to?(eligible_method_for(promotable))
    end

    # Determines if the promotable object meets this condition's eligibility requirements.
    #
    # This dispatches to the eligibility method named after the promotable's class, such as
    # `order_eligible?` or `line_item_eligible?`, which subclasses define.
    #
    # @param promotable [Object] The object to evaluate (e.g., Spree::Order, Spree::LineItem)
    # @param ... [args, kwargs] Additional arguments passed to the eligibility method
    #
    # @return [Boolean] true if the promotable meets the condition, false otherwise
    # @raise [NotImplementedError] if the condition is not applicable to the promotable
    #
    # @see #eligibility_errors
    def eligible?(promotable, ...)
      if applicable?(promotable)
        send(eligible_method_for(promotable), promotable, ...)
      else
        raise NotImplementedError, "Please implement #{eligible_method_for(promotable)} in your condition"
      end
    end

    def self.inherited(klass)
      def klass.method_added(method_added)
        if method_added == :eligible?
          Spree.deprecator.warn <<~MSG
            Please refactor `#{name}`. You're defining `eligible?`. Instead, define method for each type of promotable
            that your condition can be applied to. For example:
            ```
            class MyCondition < SolidusPromotions::Condition
              def applicable?(promotable)
                promotable.is_a?(Spree::Order)
              end

              def eligible?(order)
                order.total > 20
              end
            ```
            can now become
            ```
            class MyCondition < SolidusPromotions::Condition
              def order_eligible?(order)
                order.total > 20
              end
            end
            ```
          MSG
        end
        super
      end
      super
    end

    def level
      raise NotImplementedError, "level should be implemented in a sub-class of SolidusPromotions::Condition"
    end
    deprecate :level, deprecator: Spree.deprecator

    # Returns an errors object for tracking eligibility failures.
    #
    # When an eligibility method determines that a promotable doesn't meet the condition,
    # it should add descriptive errors to this object. These errors are used to
    # provide feedback about why a promotion isn't being applied.
    #
    # @return [ActiveModel::Errors] An errors collection for this condition
    #
    # @example Adding an eligibility error
    #   def order_eligible?(order, _options = {})
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

    def eligible_method_for(promotable)
      self.class.eligible_method_for(promotable.class)
    end

    # Validates that only one instance of this condition type exists per benefit.
    #
    # Prevents duplicate conditions of the same type from being added to a single benefit.
    def unique_per_benefit
      return unless self.class.exists?(benefit_id: benefit_id, type: self.class.name)

      errors.add(:benefit, :already_contains_condition_type)
    end

    # Validates that this condition type is allowed for the associated benefit.
    #
    # Checks the benefit class's {Benefit.applicable_conditions} to ensure this condition
    # type is compatible.
    def possible_condition_for_benefit
      benefit.class.applicable_conditions.include?(self.class) || errors.add(:type, :invalid_condition_type)
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
