require 'rails_helper'

module Spree
  RSpec.describe Spree::Order, type: :model do
    context "email validation" do
      let(:store) { create(:store) }
      let(:order) { Spree::Order.create!(store: store, state: state, email: email) }

      shared_examples "email validated" do
        # Regression test for https://github.com/spree/spree/issues/1238
        context "with quote in email" do
          let(:email) { "o'brien@gmail.com" }
          it "o'brien@gmail.com is a valid email address" do
            expect(order).to be_valid
          end
        end

        context "with blank email" do
          let(:email) { nil }

          # Regression test for https://github.com/spree/spree/issues/2214
          it "Returns a single error message" do
            expect(order).not_to be_valid
            expect(order.errors[:email]).to eq(["can't be blank"])
          end
        end
      end

      shared_examples "email not validated" do
        context "with blank email" do
          let(:email) { nil }
          it "is valid" do
            order.email = nil
            expect(order).to be_valid
            expect(order.error_on(:email).size).to eq(0)
          end
        end
      end

      context "new record" do
        let(:order) { Spree::Order.new(store: store) }
        it_behaves_like "email not validated"
      end

      %w[cart address].each do |state_name|
        context "#{state_name} state" do
          let(:state) { state_name }
          it_behaves_like "email not validated"
        end
      end

      %w[payment confirm complete].each do |state_name|
        context "#{state_name} state" do
          let(:state) { state_name }
          it_behaves_like "email validated"
        end
      end
    end
  end
end
