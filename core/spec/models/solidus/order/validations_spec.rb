require 'spec_helper'

module Solidus
  describe Solidus::Order, :type => :model do
    context "validations" do
      # Regression test for #2214
      it "does not return two error messages when email is blank" do
        order = Solidus::Order.new
        allow(order).to receive_messages(:require_email => true)
        order.valid?
        expect(order.errors[:email]).to eq(["can't be blank"])
      end
    end
  end
end
