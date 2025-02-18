# frozen_string_literal: true

@product_attributes ||= product_attributes
json.cache! [I18n.locale, @current_user_roles.include?("admin"), current_pricing_options, @product_attributes, @exclude_data, product] do
  json.call(product, *(@product_attributes - [:total_on_hand]))
  json.total_on_hand(total_on_hand_for(product))
  json.price(product.price_for_options(current_pricing_options)&.amount)
  json.display_price(product.price_for_options(current_pricing_options)&.money&.to_s)

  @exclude_data ||= {}
  unless @exclude_data[:variants]
    json.has_variants(product.has_variants?)
    json.master do
      json.partial!("spree/api/variants/small", variant: product.master)
    end
    json.variants(product.variants) do |variant|
      json.partial!("spree/api/variants/small", variant:)
    end
  end
  unless @exclude_data[:option_types]
    json.option_types(product.option_types) do |option_type|
      json.call(option_type, *option_type_attributes)
    end
  end
  unless @exclude_data[:product_properties]
    json.product_properties(product.product_properties) do |product_property|
      json.call(product_property, *product_property_attributes)
    end
  end
  unless @exclude_data[:classifications]
    json.classifications(product.classifications) do |classification|
      json.call(classification, :taxon_id, :position)
      json.taxon do
        json.partial!("spree/api/taxons/taxon", taxon: classification.taxon)
      end
    end
  end
end
