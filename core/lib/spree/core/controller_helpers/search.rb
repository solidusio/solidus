# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module Search
        def build_searcher(params)
          Spree::Deprecation.warn(
            'This module will be moving the to solidus_frontend gem,
            If you have not already done so, please update to the latest
            solidus_frontend version which will remove this deprication flag'
          )

          Spree::Config.searcher_class.new(params).tap do |searcher|
            searcher.current_user = spree_current_user
            searcher.pricing_options = current_pricing_options
          end
        end
      end
    end
  end
end
