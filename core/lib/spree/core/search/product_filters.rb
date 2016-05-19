module Spree
  module Core
    module Search
      class ProductFilters
        # @return [String] The path to the partial used for product filters
        attr_reader :partial_path

        # @param partial_path [String]
        #   The path to the partial you want to use to render the filters
        # @param taxon [Spree::Taxon]
        #   The taxon object you may want to use to filter products
        # @raise [RuntimeError]
        #   when the partial_path parameter is empty
        def initialize(partial_path: 'spree/shared/sidebar_filters', taxon: nil)
          @filters      = []
          @partial_path = partial_path.presence ||
                          fail('partial_path needs to be set')

          if taxon.nil?
            @filters << Spree::Core::ProductFilters.all_taxons
          else
            @filters << Spree::Core::ProductFilters.price_filter
            @filters << Spree::Core::ProductFilters.brand_filter
          end
        end

        # @return [Array] The list of configured product filters
        def all
          @filters
        end
      end
    end
  end
end
