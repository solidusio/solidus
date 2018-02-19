# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module Search
        def build_searcher(params)
          Spree::Config.searcher_class.new(params).tap do |searcher|
            searcher.current_user = try_spree_current_user
            searcher.pricing_options = current_pricing_options
          end
        end
      end
    end
  end
end
