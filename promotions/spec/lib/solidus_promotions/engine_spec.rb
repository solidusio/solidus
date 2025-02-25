# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusPromotions::Engine do
  describe "initializer.flickwerk_alias" do
    it "sets the Flickwerk alias for order_recalculator_class" do
      Flickwerk.aliases["Spree::Config.order_recalculator_class"] = nil

      require "solidus_promotions/engine"
      expect(Flickwerk.aliases["Spree::Config.order_recalculator_class"]).to be_nil

      initializer = SolidusPromotions::Engine.initializers.find { |i| i.name == "solidus_promotions.flickwerk_alias" }
      initializer.run
      expect(Flickwerk.aliases["Spree::Config.order_recalculator_class"]).to eq("Spree::OrderUpdater")
    end
  end
end
