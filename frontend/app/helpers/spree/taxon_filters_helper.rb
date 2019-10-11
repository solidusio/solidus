# frozen_string_literal: true

require 'spree/core/product_filters'

module Solidus
  module TaxonFiltersHelper
    def applicable_filters_for(_taxon)
      [:brand_filter, :price_filter].map do |filter_name|
        Solidus::Core::ProductFilters.send(filter_name) if Solidus::Core::ProductFilters.respond_to?(filter_name)
      end.compact
    end
  end
end
