# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Friendly Factories" do
  it "has a bunch of working factories" do
    [
      :friendly_promotion,
      :friendly_promotion_with_benefit_adjustment,
      :friendly_promotion_with_item_adjustment,
      :friendly_promotion_with_order_adjustment,
      :friendly_shipping_rate_discount
    ].each do |factory|
      expect { FactoryBot.create(factory) }.not_to raise_exception
    end
  end
end
