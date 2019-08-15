# frozen_string_literal: true

module Spree
  # Base class for all promotion rules
  class PromotionRule < Spree::Base
    belongs_to :promotion, class_name: 'Spree::Promotion', inverse_of: :promotion_rules, optional: true

    scope :of_type, ->(type) { where(type: type) }

    validates :promotion, presence: true
    validate :unique_per_promotion, on: :create

    def self.for(promotable)
      all.select { |rule| rule.applicable?(promotable) }
    end

    def applicable?(_promotable)
      raise NotImplementedError, "applicable? should be implemented in a sub-class of Spree::PromotionRule"
    end

    def eligible?(_promotable, _options = {})
      raise NotImplementedError, "eligible? should be implemented in a sub-class of Spree::PromotionRule"
    end

    # This states if a promotion can be applied to the specified line item
    # It is true by default, but can be overridden by promotion rules to provide conditions
    def actionable?(_line_item)
      true
    end

    def eligibility_errors
      @eligibility_errors ||= ActiveModel::Errors.new(self)
    end

    def to_partial_path
      "spree/admin/promotions/rules/#{model_name.element}"
    end

    private

    def unique_per_promotion
      if Spree::PromotionRule.exists?(promotion_id: promotion_id, type: self.class.name)
        errors[:base] << "Promotion already contains this rule type"
      end
    end

    def eligibility_error_message(key, options = {})
      I18n.t(key, { scope: [:spree, :eligibility_errors, :messages] }.merge(options))
    end
  end
end
