# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::SpreeLineItem::Component < SolidusAdmin::Orders::Show::Adjustments::Index::Adjustable::Component
  delegate :variant, to: :adjustable

  def caption
    options_text = variant.options_text.presence
    options_text || variant.sku
  end

  def detail
    link_to(variant.product.name, solidus_admin.product_path(variant.product), class: "body-link")
  end
end
