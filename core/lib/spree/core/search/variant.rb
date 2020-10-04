# frozen_string_literal: true

require 'active_support/core_ext/class/attribute'

module Spree
  module Core
    module Search
      #
      # NOTE: Use Spree::Config.variant_search_class rather than referencing this
      # directly.
      #

      class Variant
        class_attribute :search_terms
        self.search_terms = [
          :sku_cont,
          :product_name_cont,
          :product_slug_cont,
          :option_values_presentation_cont,
          :option_values_name_cont
        ]

        def initialize(query_string, scope: Spree::Variant.all)
          @query_string = query_string
          @scope = scope
        end

        # Searches the variants table using the ransack 'search_terms' defined on the class.
        # Each word of the query string is searched individually, matching by a union of the ransack
        # search terms, then we find the intersection of those queries, ensuring that each word matches
        # one of the rules.
        #
        # == Returns:
        # ActiveRecord::Relation of variants
        def results
          return @scope if @query_string.blank?

          matches = @query_string.split.map do |word|
            @scope.ransack(search_term_params(word)).result.pluck(:id)
          end

          Spree::Variant.where(id: matches.inject(:&))
        end

        private

        # Returns an array of search term symbols that will be passed to Ransack
        # to query the DB for the given word.
        # Subclasses may override this to allow conditional filtering, etc.
        #
        # @api public
        # @param _word [String] One of the search words provided by the user.
        #   e.g. a SKU
        # @return [Array<Symbol>] the list of search terms to use for this word
        def search_terms(_word)
          self.class.search_terms
        end

        def search_term_params(word)
          terms = Hash[search_terms(word).map { |term| [term, word] }]
          terms.merge(m: 'or')
        end
      end
    end
  end
end
