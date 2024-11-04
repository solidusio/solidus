# frozen_string_literal: true

FactoryBot.define do
  factory :completed_order_with_solidus_promotion, parent: :order_with_line_items do
    transient do
      completed_at { Time.current }
      promotion { nil }
    end

    after(:create) do |order, evaluator|
      promotion = evaluator.promotion || create(:solidus_promotion, code: "test")
      promotion_code = promotion.codes.first || create(:solidus_promotion_code, promotion: promotion)

      order.solidus_order_promotions.create!(promotion: promotion, promotion_code: promotion_code)
      order.recalculate
      order.update_column(:completed_at, evaluator.completed_at)
      order.update_column(:state, "complete")
    end
  end
end
