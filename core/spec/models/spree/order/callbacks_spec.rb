require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:store) { create(:store) }
  let(:order) { Spree::Order.new(store: store) }

  context "validations" do
    context "email validation" do
      # Regression test for https://github.com/spree/spree/issues/1238
      it "o'brien@gmail.com is a valid email address" do
        order.state = 'address'
        order.email = "o'brien@gmail.com"
        expect(order.error_on(:email).size).to eq(0)
      end
    end
  end

  context "#save" do
    context "when associated with a registered user" do
      let(:user) { create(:user, email: "test@example.com") }

      it "should assign the email address of the user" do
        order.user = user
        order.save!
        expect(order.email).to eq(user.email)
      end
    end
  end

  context "in the cart state" do
    it "should not validate email address" do
      order.state = "cart"
      order.email = nil
      order.save!
      expect(order.error_on(:email).size).to eq(0)
    end
  end
end
