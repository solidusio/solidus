# frozen_string_literal: true

require 'rails_helper'

module Solidus
  RSpec.describe Solidus::Order, type: :model do
    context "validations" do
      # Regression test for https://github.com/spree/spree/issues/2214
      it "does not return two error messages when email is blank" do
        order = Solidus::Order.new
        allow(order).to receive_messages(require_email: true)
        order.valid?
        expect(order.errors[:email]).to eq(["can't be blank"])
      end
    end
  end
end
