# frozen_string_literal: true

require "rails_helper"
require "solidus_promotions/promotion_map"
require "solidus_promotions/promotion_migrator"

RSpec.describe "Promotion System" do
  describe "with an in-memory order recalculator" do
    around do |example|
      prev_recalculator_class = Spree::Config.order_recalculator_class
      Spree::Config.order_recalculator_class = Spree::InMemoryOrderUpdater

      example.run

      Spree::Config.order_recalculator_class = prev_recalculator_class
    end

    it_behaves_like "a successfully integrated promotion system"
  end
end
