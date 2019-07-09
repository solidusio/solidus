# frozen_string_literal: true

module Spree
  module Admin
    module TabsHelper
      def product_tabs(current:)
        Spree::Backend::Tabs::Product.new(view_context: self, current: current)
      end
    end
  end
end
