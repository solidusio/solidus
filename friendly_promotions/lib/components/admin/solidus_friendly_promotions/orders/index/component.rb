# frozen_string_literal: true

class SolidusFriendlyPromotions::Orders::Index::Component < SolidusAdmin::Orders::Index::Component
  def filters
    super + [
      {
        label: t(".filters.promotions"),
        combinator: "or",
        attribute: "friendly_promotions_id",
        predicate: "in",
        options: SolidusFriendlyPromotions::Promotion.all.pluck(:name, :id)
      }
    ]
  end
end
