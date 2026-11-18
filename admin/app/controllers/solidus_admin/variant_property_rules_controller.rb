# frozen_string_literal: true

module SolidusAdmin
  class VariantPropertyRulesController < SolidusAdmin::BaseController
    include SolidusAdmin::ProductSpecifications

    before_action :load_rule, only: [:edit, :update, :destroy]

    def new
      @rule = @product.variant_property_rules.build

      respond_with_form
    end

    def create
      @rule = @product.variant_property_rules.build(variant_property_rule_params)

      if option_values_given? && @rule.save
        respond_with_success(t(".success"))
      else
        respond_with_errors
      end
    end

    def edit
      respond_with_form
    end

    def update
      if option_values_given? && @rule.update(variant_property_rule_params)
        respond_with_success(t(".success"))
      else
        respond_with_errors
      end
    end

    def destroy
      @rule.destroy!

      respond_with_success(t(".success"))
    end

    private

    def authorization_subject
      Spree::Variant
    end

    def option_values_given?
      return true if variant_property_rule_params[:option_value_ids].to_a.compact_blank.any?

      @rule.errors.add(:option_values, :blank)
      false
    end

    def variant_property_rule_params
      params.require(:variant_property_rule).permit(
        :apply_to_all,
        option_value_ids: [],
        values_attributes: [:id, :property_name, :value, :_destroy]
      )
    end

    def load_rule
      @rule = @product.variant_property_rules.find(params[:id])
    end
  end
end
