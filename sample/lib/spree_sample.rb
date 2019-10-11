# frozen_string_literal: true

require 'spree_core'
require 'spree/sample'

module SolidusSample
  class Engine < Rails::Engine
    engine_name 'spree_sample'

    # Needs to be here so we can access it inside the tests
    def self.load_samples
      Solidus::Sample.load_sample("payment_methods")
      Solidus::Sample.load_sample("tax_categories")
      Solidus::Sample.load_sample("tax_rates")
      Solidus::Sample.load_sample("shipping_categories")
      Solidus::Sample.load_sample("shipping_methods")

      Solidus::Sample.load_sample("products")
      Solidus::Sample.load_sample("taxons")
      Solidus::Sample.load_sample("option_values")
      Solidus::Sample.load_sample("product_option_types")
      Solidus::Sample.load_sample("product_properties")
      Solidus::Sample.load_sample("variants")
      Solidus::Sample.load_sample("stock")
      Solidus::Sample.load_sample("assets")

      Solidus::Sample.load_sample("orders")
      Solidus::Sample.load_sample("payments")
      Solidus::Sample.load_sample("reimbursements")
    end
  end
end
