# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Friendly Factories" do
  it "has a bunch of working factories" do
    [
      :solidus_promotion,
      :solidus_promotion_with_benefit_adjustment,
      :solidus_promotion_with_item_adjustment,
      :solidus_promotion_with_order_adjustment,
      :solidus_shipping_rate_discount
    ].each do |factory|
      expect { FactoryBot.create(factory) }.not_to raise_exception
    end
  end
end
