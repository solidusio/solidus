# frozen_string_literal: true

require "rails_helper"
require "solidus_promotions/promotion_map"
require "solidus_promotions/promotion_migrator"

RSpec.describe "Promotion System" do
  describe "with the default order recalculator config" do
    around do |example|
      prev_recalculator_class = Spree::Config.order_recalculator_class
      Spree::Config.order_recalculator_class = Spree::OrderUpdater

      example.run

      Spree::Config.order_recalculator_class = prev_recalculator_class
    end

    it_behaves_like "a successfully integrated promotion system"
  end
end
