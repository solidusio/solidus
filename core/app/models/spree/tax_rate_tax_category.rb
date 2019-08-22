# frozen_string_literal: true

module Spree
  class TaxRateTaxCategory < Spree::Base
    belongs_to :tax_rate, class_name: 'Spree::TaxRate', inverse_of: :tax_rate_tax_categories, optional: true
    belongs_to :tax_category, class_name: 'Spree::TaxCategory', inverse_of: :tax_rate_tax_categories, optional: true
  end
end
