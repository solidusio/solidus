# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeLineItemDecorator
    def total_before_tax
      amount + adjustments.select { |value| !value.tax? && value.eligible? }.sum(&:amount)
    end

    Spree::LineItem.prepend self
  end
end
