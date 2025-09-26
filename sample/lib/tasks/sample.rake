# frozen_string_literal: true

require "pathname"
require "spree/sample"

namespace :spree_sample do
  desc "Loads sample data"
  task load: :environment do
    if ARGV.include?("db:migrate")
      puts <<~TEXT
        Please run db:migrate separately from spree_sample:load.

        Running db:migrate and spree_sample:load at the same time has been known to
        cause problems where columns may be not available during sample data loading.

        Migrations have been run. Please run "rake spree_sample:load" by itself now.
      TEXT
      exit(1)
    end

    SpreeSample::Engine.load_samples
  end
end
