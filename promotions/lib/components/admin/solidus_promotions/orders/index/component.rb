# frozen_string_literal: true

class SolidusPromotions::Orders::Index::Component < SolidusAdmin::Orders::Index::Component
  def filters
    super + [
      {
        label: t(".filters.promotions"),
        combinator: "or",
        attribute: "solidus_promotions_id",
        predicate: "in",
        options: SolidusPromotions::Promotion.all.pluck(:name, :id)
      }
    ]
  end
end
