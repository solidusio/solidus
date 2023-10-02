# frozen_string_literal: true

module SolidusFriendlyPromotions
  module LineItemDecorator
    Spree::LineItem.prepend SolidusFriendlyPromotions::DiscountableAmount
  end
end
