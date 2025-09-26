# frozen_string_literal: true

require "spree_core"
require "spree/sample"

module SpreeSample
  class Engine < Rails::Engine
    engine_name "spree_sample"

    # Needs to be here so we can access it inside the tests
    def self.load_samples
      original_active_job_adapter = ActiveJob::Base.queue_adapter

      # SQLite doesn't support full-concurrency and often fails with
      # "SQLite3::BusyException: database is locked" when ActiveJob uses the default
      # threaded `:async` adapter. ActiveJob is used by ActiveStorage to analyze uploaded
      # images for metadata.
      if ActiveRecord::Base.connection.adapter_name == "SQLite"
        ActiveJob::Base.queue_adapter = :inline
      end

      Spree::Sample.load_sample("payment_methods")
      Spree::Sample.load_sample("tax_categories")
      Spree::Sample.load_sample("tax_rates")
      Spree::Sample.load_sample("shipping_categories")
      Spree::Sample.load_sample("shipping_methods")

      Spree::Sample.load_sample("products")
      Spree::Sample.load_sample("taxons")
      Spree::Sample.load_sample("option_values")
      Spree::Sample.load_sample("product_option_types")
      Spree::Sample.load_sample("product_properties")
      Spree::Sample.load_sample("variants")
      Spree::Sample.load_sample("stock")
      Spree::Sample.load_sample("assets")

      Spree::Sample.load_sample("orders")
      Spree::Sample.load_sample("payments")
      Spree::Sample.load_sample("reimbursements")
    ensure
      ActiveJob::Base.queue_adapter = original_active_job_adapter
    end
  end
end
