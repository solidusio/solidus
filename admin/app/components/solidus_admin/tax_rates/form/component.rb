# frozen_string_literal: true

class SolidusAdmin::TaxRates::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(tax_rate:, form_url:, form_id:)
    @tax_rate = tax_rate
    @form_url = form_url
    @form_id = form_id
  end

  private

  def zone_options
    @zone_options ||= Spree::Zone.order(:name).map { [_1.name, _1.id] }
  end

  def tax_category_options
    @tax_category_options ||= Spree::TaxCategory.order(:name).map { [_1.name, _1.id] }
  end

  def calculator_options
    @calculator_options ||= Rails.application.config.spree.calculators.tax_rates.map { [_1.description, _1.name] }
  end

  def level_options
    @level_options ||= Spree::TaxRate.levels.keys.map { [t(".levels.#{_1}"), _1] }
  end
end
