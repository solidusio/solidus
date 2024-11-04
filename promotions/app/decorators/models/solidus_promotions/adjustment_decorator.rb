# frozen_string_literal: true

module SolidusPromotions
  module AdjustmentDecorator
    def self.prepended(base)
      base.scope :solidus_promotion, -> { where(source_type: "SolidusPromotions::Benefit") }
    end

    Spree::Adjustment.prepend self
  end
end
