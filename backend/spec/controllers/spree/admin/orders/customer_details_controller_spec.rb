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
        spree_put :update, attributes
      end

      it "does refresh the shipment rates with all shipping methods" do
        expect(order).to receive(:refresh_shipment_rates)
        attributes = { order_id: order.number, order: { email: "" } }
        spree_put :update, attributes
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
          expect { spree_put :update, attributes }.to change { order.reload.email }.to eq 'foo@bar.com'
          expect(response).to be_redirect
        end
      end

      context "false guest checkout param" do
        it "attempts to associate the user" do
          mock_user = mock_model(Spree.user_class, id: 1)
          allow(Spree.user_class).to receive(:find) { mock_user }
          expect(order.contents).to receive(:associate_user).with(mock_user, true)
          attributes = {
            order_id: order.number,
            user_id: mock_user.id,
            guest_checkout: 'false',
            order: { email: "" }
          }
          spree_put :update, attributes
        end
      end

      context "not false guest checkout param" do
        it "does not attempt to associate the user" do
          allow(order).to receive_messages(update_attributes: true,
                                           next: false,
                                           refresh_shipment_rates: true)

          expect(order.contents).not_to receive(:associate_user)

          attributes = {
            order_id: order.number,
            order: { email: "foo@example.com" }
          }
          spree_put :update, attributes
        end
      end
    end
  end
end
