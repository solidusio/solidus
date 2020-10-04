# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:order) { stub_model('Spree::Order') }

  describe ".is_risky?" do
    context "Not risky order" do
      let(:order) { FactoryBot.create(:order, payments: [payment]) }
      context "with avs_response == D" do
        let(:payment) { FactoryBot.create(:payment, avs_response: "D") }
        it "is not considered risky" do
          expect(order.is_risky?).to eq(false)
        end
      end

      context "with avs_response == M" do
        let(:payment) { FactoryBot.create(:payment, avs_response: "M") }
        it "is not considered risky" do
          expect(order.is_risky?).to eq(false)
        end
      end

      context "with avs_response == ''" do
        let(:payment) { FactoryBot.create(:payment, avs_response: "") }
        it "is not considered risky" do
          expect(order.is_risky?).to eq(false)
        end
      end

      context "with cvv_response_code == M" do
        let(:payment) { FactoryBot.create(:payment, cvv_response_code: "M") }
        it "is not considered risky" do
          expect(order.is_risky?).to eq(false)
        end
      end

      context "with cvv_response_message == ''" do
        let(:payment) { FactoryBot.create(:payment, cvv_response_message: "") }
        it "is not considered risky" do
          expect(order.is_risky?).to eq(false)
        end
      end
    end

    context "Risky order" do
      context "AVS response message" do
        let(:order) { FactoryBot.create(:order, payments: [FactoryBot.create(:payment, avs_response: "A")]) }
        it "returns true if the order has an avs_response" do
          expect(order.is_risky?).to eq(true)
        end
      end

      context "CVV response code" do
        let(:order) { FactoryBot.create(:order, payments: [FactoryBot.create(:payment, cvv_response_code: "N")]) }
        it "returns true if the order has an cvv_response_code" do
          expect(order.is_risky?).to eq(true)
        end
      end

      context "state == 'failed'" do
        let(:order) { FactoryBot.create(:order, payments: [FactoryBot.create(:payment, state: 'failed')]) }
        it "returns true if the order has state == 'failed'" do
          expect(order.is_risky?).to eq(true)
        end
      end
    end
  end
end
