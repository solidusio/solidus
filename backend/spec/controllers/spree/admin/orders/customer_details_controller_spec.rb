require "spec_helper"
require "cancan"
require "spree/testing_support/bar_ability"

describe Spree::Admin::Orders::CustomerDetailsController, type: :controller do
  context "with authorization" do
    stub_authorization!

    let(:order) { create(:order, number: "R123456789") }

    before { allow(Spree::Order).to receive(:find_by_number!) { order } }

    context "#update" do
      it "updates + progresses the order" do
        expect(order).to receive(:update_attributes) { true }
        expect(order).to receive(:next) { false }
        attributes = { order_id: order.number, order: { email: "" } }
        put :update, attributes
      end

      it "does refresh the shipment rates with all shipping methods" do
        expect(order).to receive(:refresh_shipment_rates)
        attributes = { order_id: order.number, order: { email: "" } }
        put :update, attributes
      end

      # Regression spec
      context 'completed order' do
        let(:order) { create(:shipped_order) }
        let(:attributes) do
          {
            order_id: order.number,
            guest_checkout: 'false',
            user_id: order.user_id,
            order: { email: "foo@bar.com" }
          }
        end

        it 'allows the updating of an email address' do
          expect { put :update, attributes }.to change { order.reload.email }.to eq 'foo@bar.com'
          expect(response).to be_redirect
        end
      end

      context "false guest checkout param" do
        let!(:assigned_user){ create :user }
        it "attempts to associate the user" do
          attributes = {
            order_id: order.number,
            user_id: assigned_user.id,
            guest_checkout: 'false',
            order: { email: "" }
          }

          expect {
            put :update, attributes
          }.to change{ order.reload.user }.to(assigned_user)
        end
      end

      context "not false guest checkout param" do
        it "does not attempt to associate the user" do
          allow(order).to receive_messages(update_attributes: true,
                                           next: false,
                                           refresh_shipment_rates: true)

          attributes = {
            order_id: order.number,
            order: { email: "foo@example.com" }
          }

          expect {
            put :update, attributes
          }.not_to change{ order.reload.user }
        end
      end
    end
  end
end
