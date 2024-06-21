# frozen_string_literal: true

FactoryBot.define do
  factory :completed_order_with_promotion, parent: :order_with_line_items do
    transient do
      completed_at { Time.current }
      promotion { nil }
    end

    after(:create) do |order, evaluator|
      promotion = evaluator.promotion || create(:promotion, code: "test")
      promotion_code = promotion.codes.first || create(:promotion_code, promotion: promotion)

      promotion.activate(order: order, promotion_code: promotion_code)
      order.order_promotions.create!(promotion: promotion, promotion_code: promotion_code)

      # Complete the order after the promotion has been activated
      order.update_column(:completed_at, evaluator.completed_at)
      order.update_column(:state, "complete")
    end
  end
end
