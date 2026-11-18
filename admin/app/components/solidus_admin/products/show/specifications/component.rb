# frozen_string_literal: true

class SolidusAdmin::Products::Show::Specifications::Component < SolidusAdmin::BaseComponent
  Group = Struct.new(:title, :scope, :values, :edit_href, keyword_init: true)

  def initialize(product:)
    @product = product
  end

  private

  def groups
    [general_group, *rule_groups]
  end

  def general_group
    Group.new(
      title: t(".general"),
      scope: t(".all_variants"),
      values: product_properties.map { |product_property| "#{product_property.property.presentation}:#{product_property.value}" },
      edit_href: solidus_admin.edit_product_product_properties_path(@product)
    )
  end

  def rule_groups
    variant_property_rules.map do |rule|
      Group.new(
        title: variant_property_rule_title(rule),
        scope: t(".matching_variants", count: matching_variants_count(rule), total: variants.size),
        values: rule.values.map { |rule_value| "#{rule_value.property.presentation}:#{rule_value.value}" },
        edit_href: solidus_admin.edit_product_variant_property_rule_path(@product, rule)
      )
    end
  end

  def product_properties
    @product.product_properties.includes(:property)
  end

  def variant_property_rules
    @product.variant_property_rules
      .includes(option_values: :option_type, values: :property)
      .order(:id)
  end

  def variants
    @variants ||= @product.variants.includes(:option_values).to_a
  end

  def matching_variants_count(rule)
    variants.count { |variant| rule.applies_to_variant?(variant) }
  end

  def variant_property_rule_title(rule)
    rule.option_values
      .map { |option_value| "#{option_value.option_type.presentation}: #{option_value.presentation}" }
      .join(rule.apply_to_all ? " + " : ", ")
  end
end
