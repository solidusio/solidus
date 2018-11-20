# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Rules::NoOtherPromotion, type: :model do
  let(:rule) { Spree::Promotion::Rules::NoOtherPromotion.new }

  context "with no other promotions" do
    let(:order) { mock_model(Spree::Order, promotions: nil) }
    it "should be eligible" do
      expect(rule).to be_eligible(order)
    end
  end

  context "with another promotion" do
    let(:promotion) { FactoryBot.create :promotion }
    let(:order) { mock_model(Spree::Order,
                             promotions: promotion) }

    it "should not be eligible" do
      expect(rule).not_to be_eligible(order)
    end
  end
end
