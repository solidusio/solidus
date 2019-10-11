# frozen_string_literal: true

module Solidus
  class TaxRateTaxCategory < Solidus::Base
    belongs_to :tax_rate, class_name: 'Solidus::TaxRate', inverse_of: :tax_rate_tax_categories, optional: true
    belongs_to :tax_category, class_name: 'Solidus::TaxCategory', inverse_of: :tax_rate_tax_categories, optional: true
  end
end
