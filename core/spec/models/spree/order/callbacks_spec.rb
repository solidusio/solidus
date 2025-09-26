# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Order, type: :model do
  let(:order) { stub_model(Spree::Order) }
  before do
    Spree::Order.define_state_machine!
  end

  context "validations" do
    context "email validation" do
      # Regression test for https://github.com/spree/spree/issues/1238
      it "o'brien@gmail.com is a valid email address" do
        order.state = "address"
        order.email = "o'brien@gmail.com"
        expect(order.errors[:email].size).to eq(0)
      end
    end
  end

  context "#save" do
    context "when associated with a registered user" do
      let(:user) { double(:user, email: "test@example.com") }

      before do
        allow(order).to receive_messages(user:)
      end

      it "should assign the email address of the user" do
        order.run_callbacks(:create)
        expect(order.email).to eq(user.email)
      end
    end
  end

  context "in the cart state" do
    it "should not validate email address" do
      order.state = "cart"
      order.email = nil
      expect(order.errors[:email].size).to eq(0)
    end
  end
end
