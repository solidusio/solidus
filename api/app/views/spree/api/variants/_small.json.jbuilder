# frozen_string_literal: true

json.cache! [I18n.locale, current_pricing_options, variant] do
  json.call(variant, *variant_attributes)
  json.price(variant.price_for_options(current_pricing_options)&.amount)
  json.display_price(variant.price_for_options(current_pricing_options)&.money&.to_s)
  json.options_text(variant.options_text)
  json.track_inventory(variant.should_track_inventory?)
  json.in_stock(variant.in_stock?)
  json.is_backorderable(variant.is_backorderable?)

  json.total_on_hand(total_on_hand_for(variant))

  json.is_destroyed(variant.destroyed?)
  json.option_values(variant.option_values) do |option_value|
    json.call(option_value, *option_value_attributes)
  end
  json.images(variant.gallery.images) do |image|
    json.partial!("spree/api/images/image", image:)
  end
end
