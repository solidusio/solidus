# frozen_string_literal: true

require "spree/preferences/persistable"

module SolidusFriendlyPromotions
  class Condition < Spree::Base
    include Spree::Preferences::Persistable

    belongs_to :benefit, class_name: "SolidusFriendlyPromotions::Benefit", inverse_of: :conditions, optional: true
    has_one :promotion, through: :benefit

    scope :of_type, ->(type) { where(type: type) }

    validate :unique_per_benefit, on: :create
    validate :possible_condition_for_benefit, if: -> { benefit.present? }

    def preload_relations
      []
    end

    def applicable?(_promotable)
      raise NotImplementedError, "applicable? should be implemented in a sub-class of SolidusFriendlyPromotions::Rule"
    end

    def eligible?(_promotable, _options = {})
      raise NotImplementedError, "eligible? should be implemented in a sub-class of SolidusFriendlyPromotions::Rule"
    end

    def level
      raise NotImplementedError, "level should be implemented in a sub-class of SolidusFriendlyPromotions::Rule"
    end

    def eligibility_errors
      @eligibility_errors ||= ActiveModel::Errors.new(self)
    end

    def to_partial_path
      "solidus_friendly_promotions/admin/condition_fields/#{model_name.element}"
    end

    def updateable?
      preferences.any?
    end

    private

    def unique_per_benefit
      return unless self.class.exists?(benefit_id: benefit_id, type: self.class.name)

      errors.add(:benefit, :already_contains_condition_type)
    end

    def possible_condition_for_benefit
      benefit.possible_conditions.include?(self.class) || errors.add(:type, :invalid_condition_type)
    end

    def eligibility_error_message(key, options = {})
      I18n.t(key, scope: [:solidus_friendly_promotions, :eligibility_errors, self.class.name.underscore], **options)
    end
  end
end
