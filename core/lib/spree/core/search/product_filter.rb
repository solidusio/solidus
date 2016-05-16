module Spree
  module Core
    module Search
      class ProductFilter
        attr_reader :filters

        def initialize(taxon = nil)
          @filters = []

          if taxon.nil?
            @filters << Spree::Core::ProductFilters.all_taxons
          else
            # @filters << Spree::Core::ProductFilters.taxons_below(taxon)
            ## unless it's a root taxon? left open for demo purposes

            @filters << Spree::Core::ProductFilters.price_filter
            @filters << Spree::Core::ProductFilters.brand_filter
          end
        end

        def self.partial_path
          'spree/shared/sidebar_filters'
        end
      end
    end
  end
end
