module Spree
  module Core
    module ControllerHelpers
      module Search
        def build_searcher params
          Solidus::Config.searcher_class.new(params).tap do |searcher|
            searcher.current_user = try_spree_current_user
            searcher.current_currency = current_currency
          end
        end
      end
    end
  end
end
