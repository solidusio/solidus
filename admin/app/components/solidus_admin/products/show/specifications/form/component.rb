# frozen_string_literal: true

class SolidusAdmin::Products::Show::Specifications::Form::Component < SolidusAdmin::BaseComponent
  # @param product [Spree::Product] the product whose specifications are edited
  # @param rule [Spree::VariantPropertyRule, nil] the rule being added or
  #   edited; when nil the dialog edits the product's own properties (General)
  def initialize(product:, rule: nil)
    @product = product
    @rule = rule
  end

  private

  def rule? = @rule.present?

  def new_rule? = rule? && @rule.new_record?

  def title
    new_rule? ? t(".add_title") : t(".edit_title")
  end

  def form_object
    @rule || @product
  end

  def form_id
    rule? ? dom_id(@rule, :specifications) : dom_id(@product, :product_properties)
  end

  def form_url
    if new_rule?
      solidus_admin.product_variant_property_rules_path(@product)
    elsif rule?
      solidus_admin.product_variant_property_rule_path(@product, @rule)
    else
      solidus_admin.product_product_properties_path(@product)
    end
  end

  def form_method
    new_rule? ? :post : :patch
  end

  def new_row_path
    if rule?
      solidus_admin.new_product_variant_property_rule_value_path(@product, variant_property_rule_id: @rule.id)
    else
      solidus_admin.new_product_product_properties_path(@product)
    end
  end

  def rows_association
    rule? ? :values : :product_properties
  end

  def option_value_choices
    @product.option_types.includes(:option_values).flat_map do |option_type|
      option_type.option_values.map do |option_value|
        ["#{option_type.presentation}: #{option_value.presentation}", option_value.id]
      end
    end
  end

  def variants_count
    @product.variants.count
  end

  def matching_variants_count
    @product.variants.includes(:option_values).count { |variant| @rule.applies_to_variant?(variant) }
  end
end
