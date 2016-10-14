object @product
cache [I18n.locale, @current_user_roles.include?('admin'), current_pricing_options, root_object]

@product_attributes ||= product_attributes
attributes(*@product_attributes)

node(:display_price) { |p| p.display_price.to_s }

@exclude_data ||= {}
unless @exclude_data[:variants]
  node(:has_variants) { |p| p.has_variants? }

  child :master => :master do
    extends "spree/api/variants/small"
  end

  child :variants => :variants do
    extends "spree/api/variants/small"
  end
end

unless @exclude_data[:option_types]
  child :option_types => :option_types do
    attributes(*option_type_attributes)
  end
end

unless @exclude_data[:product_properties]
  child :product_properties => :product_properties do
    attributes(*product_property_attributes)
  end
end

unless @exclude_data[:classifications]
  child :classifications => :classifications do
    attributes :taxon_id, :position

    child(:taxon) do
      extends "spree/api/taxons/show"
    end
  end
end
