# frozen_string_literal: true

module SolidusPromotions
  class ProductAdvertiser
    attr_reader :order, :product, :promotions, :quantity

    def initialize(product:, order:, quantity: 1)
      @product = product
      @order = order
      @quantity = quantity
      @promotions = SolidusPromotions::LoadPromotions.new(order:).call
    end

    def call
      return unless product.promotionable?

      SolidusPromotions::Promotion.ordered_lanes.each do |lane|
        SolidusPromotions::PromotionLane.set(current_lane: lane) do
          lane_promotions = promotions.select { |promotion| promotion.lane == lane }
          lane_benefits = eligible_benefits_for_promotable(lane_promotions.flat_map(&:benefits), order)

          if product.has_variants?
            product.variants.each { |variant| discount_variant(variant, lane_benefits) }
          else
            discount_variant(product.master, lane_benefits)
          end
        end
      end
    end

    private

    def discount_variant(variant, benefits)
      variant.prices.each do |price|
        next if price.discarded?
        discounts = generate_discounts(benefits, price)
        chosen_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
        price.discounts.concat(chosen_discounts)
      end
    end

    def eligible_benefits_for_promotable(possible_benefits, promotable)
      possible_benefits.select do |candidate|
        candidate.eligible_by_applicable_conditions?(promotable)
      end
    end

    def generate_discounts(possible_benefits, item)
      eligible_benefits = eligible_benefits_for_promotable(possible_benefits, item)
      eligible_benefits.filter_map do |benefit|
        next unless benefit.can_discount?(item)

        benefit.discount(item, order:, quantity:)
      end
    end
  end
end
