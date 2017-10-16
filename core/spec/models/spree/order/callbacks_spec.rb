require 'rails_helper'

RSpec.describe Spree::Order, type: :model do
  let(:store) { create(:store) }
  let(:order) { Spree::Order.new(store: store) }

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
end
