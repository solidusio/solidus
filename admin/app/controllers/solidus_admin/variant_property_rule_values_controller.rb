# frozen_string_literal: true

module SolidusAdmin
  class VariantPropertyRuleValuesController < SolidusAdmin::BaseController
    include SolidusAdmin::ProductSpecifications

    before_action :load_rule

    def new
      @value = @rule.values.build

      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def authorization_subject
      Spree::Variant
    end

    def load_rule
      @rule = if params[:variant_property_rule_id].present?
        @product.variant_property_rules.find(params[:variant_property_rule_id])
      else
        @product.variant_property_rules.build
      end
    end
  end
end
