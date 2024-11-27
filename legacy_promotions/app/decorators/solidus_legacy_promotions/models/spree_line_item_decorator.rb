# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeLineItemDecorator
    def self.prepended(base)
      base.has_many :line_item_actions, dependent: :destroy
      base.has_many :actions, through: :line_item_actions
    end

    def total_before_tax
      amount + adjustments.select { |value| !value.tax? && value.eligible? }.sum(&:amount)
    end

    Spree::LineItem.prepend self
  end
end
