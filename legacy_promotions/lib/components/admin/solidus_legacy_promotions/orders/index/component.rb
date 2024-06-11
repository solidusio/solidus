# frozen_string_literal: true

class SolidusLegacyPromotions::Orders::Index::Component < SolidusAdmin::Orders::Index::Component
  def filters
    super + [
      {
        label: t('.filters.promotions'),
        combinator: 'or',
        attribute: "promotions_id",
        predicate: "in",
        options: Spree::Promotion.all.pluck(:name, :id),
      }
    ]
  end
end
