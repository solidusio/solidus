# frozen_string_literal: true

module SolidusPromotions
  class ProductDiscounter
    attr_reader :order, :product, :pricing_options, :promotions, :quantity

    def initialize(product:, order:, pricing_options:, quantity: 1)
      @product = product
      @order = order
      @pricing_options = pricing_options
      @quantity = quantity
      @promotions = SolidusPromotions::LoadPromotions.new(order:).call
    end

    def call
      if product.has_variants?
        product.variants.each { |variant| discount_variant(variant) }
      else
        discount_variant(product.master)
      end
    end

    private

    def discount_variant(variant)
      variant.discountable_price = variant.price_for_options(pricing_options)

      return unless variant.product.promotionable?

      SolidusPromotions::Promotion.ordered_lanes.each_key do |lane|
        lane_promotions = promotions.select { |promotion| promotion.lane == lane }
        lane_benefits = eligible_benefits_for_promotable(lane_promotions.flat_map(&:benefits), order)
        discounts = generate_discounts(lane_benefits, variant.discountable_price)
        chosen_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
        variant.discountable_price.current_discounts.concat(chosen_discounts)
      end
    end

    def eligible_benefits_for_promotable(possible_benefits, promotable)
      possible_benefits.select do |candidate|
        candidate.eligible_by_applicable_conditions?(promotable)
      end
    end

    def generate_discounts(possible_benefits, item)
      eligible_benefits = eligible_benefits_for_promotable(possible_benefits, item)
      eligible_benefits.select do |benefit|
        benefit.can_discount?(item)
      end.map do |benefit|
        benefit.discount(item, order:, quantity:)
      end.compact
    end
  end
end
