# frozen_string_literal: true

module Solidus
  module Admin
    module ProductsHelper
      def show_rebuild_vat_checkbox?
        Solidus::TaxRate.included_in_price.exists?
      end
    end
  end
end
