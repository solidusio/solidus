# frozen_string_literal: true

class SolidusAdmin::Products::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  include SolidusAdmin::Products::FormOptions

  def initialize(product:)
    @product = product
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@product.id}"
  end

  def selected_category_options = @product.taxons.map { [_1.pretty_name, _1.id] }

  def product_properties
    @product_properties ||= @product.product_properties.includes(:property)
  end

  def variant_property_rules
    @variant_property_rules ||= @product.variant_property_rules
      .includes(option_values: :option_type, values: :property)
      .order(:id)
  end

  def variant_property_rule_title(rule)
    rule.option_values.map { |option_value| "#{option_value.option_type.presentation}:#{option_value.presentation}" }.join(", ")
  end
end
