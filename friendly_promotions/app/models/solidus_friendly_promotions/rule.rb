# frozen_string_literal: true

require 'spree/preferences/persistable'

module SolidusFriendlyPromotions
  class Rule < Spree::Base
    include Spree::Preferences::Persistable

    belongs_to :promotion

    scope :of_type, ->(type) { where(type: type) }

    validate :unique_per_promotion, on: :create

    def preload_relations
      []
    end

    def applicable?(_promotable)
      raise NotImplementedError, "applicable? should be implemented in a sub-class of SolidusFriendlyPromotions::Rule"
    end

    def eligible?(_promotable, _options = {})
      raise NotImplementedError, "eligible? should be implemented in a sub-class of SolidusFriendlyPromotions::Rule"
    end

    def eligibility_errors
      @eligibility_errors ||= ActiveModel::Errors.new(self)
    end

    def to_partial_path
      "solidus_friendly_promotions/admin/promotion_rules/rules/#{model_name.element}"
    end

    private

    def unique_per_promotion
      if self.class.exists?(promotion_id: promotion_id, type: self.class.name)
        errors[:base] << "Promotion already contains this rule type"
      end
    end

    def eligibility_error_message(key, options = {})
      I18n.t(key, **{ scope: [:spree, :eligibility_errors, :messages] }.merge(options))
    end
  end
end
