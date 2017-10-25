# frozen_string_literal: true

json.cache! [I18n.locale, line_item] do
  json.(line_item, *line_item_attributes)
  json.single_display_amount(line_item.single_display_amount.to_s)
  json.display_amount(line_item.display_amount.to_s)
  json.total(line_item.total)
  json.variant do
    json.partial!("spree/api/variants/small", variant: line_item.variant)
    json.(line_item.variant, :product_id)
    json.images(line_item.variant.gallery.images) do |image|
      json.partial!("spree/api/images/image", image: image)
    end
  end
  json.adjustments(line_item.adjustments) do |adjustment|
    json.partial!("spree/api/adjustments/adjustment", adjustment: adjustment)
  end
end
