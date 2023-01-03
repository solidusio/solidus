# frozen_string_literal: true

module Spree
  module Admin
    module ProductsHelper
      def frontend_product_path(product)
        Spree::Backend::Config[:frontend_product_path].call(self, product)
      end

      def show_rebuild_vat_checkbox?
        Spree::TaxRate.included_in_price.exists?
      end
    end
  end
end

