# frozen_string_literal: true

require "spree/preferences/persistable"

module SolidusFriendlyPromotions
  class Condition < Spree::Base
    include Spree::Preferences::Persistable

    belongs_to :action, class_name: "SolidusFriendlyPromotions::PromotionAction", inverse_of: :conditions, optional: true
    has_one :promotion, through: :action

    scope :of_type, ->(type) { where(type: type) }

    validate :unique_per_action, on: :create

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
      "solidus_friendly_promotions/admin/condition_forms/#{model_name.element}"
    end

    def updateable?
      preferences.any?
    end

    private

    def unique_per_action
      return unless self.class.exists?(action_id: action_id, type: self.class.name)

      errors.add(:action, :already_contains_condition_type)
    end

    def eligibility_error_message(key, options = {})
      I18n.t(key, scope: [:solidus_friendly_promotions, :eligibility_errors, self.class.name.underscore], **options)
    end
  end
end
