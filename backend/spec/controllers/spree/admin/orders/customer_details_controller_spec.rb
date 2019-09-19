# frozen_string_literal: true

require "spec_helper"
require "cancan"

describe Spree::Admin::Orders::CustomerDetailsController, type: :controller do
  context "with authorization" do
    stub_authorization!

    context '#edit' do
      context 'when order has no shipping nor billing address' do
        let(:order) { create(:order, number: "R123456789", ship_address: nil, bill_address: nil) }

        context "with a checkout_zone set as the country of Canada" do
          let!(:united_states) { create(:country, iso: 'US', states_required: true) }
          let!(:canada) { create(:country, iso: 'CA', states_required: true) }
          let!(:checkout_zone) { create(:zone, name: "Checkout Zone", countries: [canada]) }

          before do
            stub_spree_preferences(checkout_zone: checkout_zone.name)
          end

          context "and default_country_iso of the Canada" do
            before do
              stub_spree_preferences(default_country_iso: Spree::Country.find_by!(iso: "CA").iso)
            end

            it 'defaults the shipping address country to Canada' do
              get :edit, params: { order_id: order.number }
              expect(assigns(:order).shipping_address.country_id).to eq canada.id
            end

            it 'defaults the billing address country to Canada' do
              get :edit, params: { order_id: order.number }
              expect(assigns(:order).billing_address.country_id).to eq canada.id
            end
          end

          context "and default_country_iso of the United States" do
            before do
              stub_spree_preferences(default_country_iso: Spree::Country.find_by!(iso: "US").iso)
            end

            it 'defaults the shipping address country to nil' do
              get :edit, params: { order_id: order.number }
              expect(assigns(:order).shipping_address.country_id).to be_nil
            end

            it 'defaults the billing address country to nil' do
              get :edit, params: { order_id: order.number }
              expect(assigns(:order).billing_address.country_id).to be_nil
            end
          end
        end
      end
    end

    context "#update" do
      let(:order) { create(:order, number: "R123456789") }

      before { allow(Spree::Order).to receive_message_chain(:includes, :find_by!) { order } }

      it "updates + progresses the order" do
        expect(order).to receive(:update) { true }
        expect(order).to receive(:next) { false }
        attributes = { order_id: order.number, order: { email: "" } }
        put :update, params: attributes
      end

      it "does refresh the shipment rates with all shipping methods" do
        expect(order).to receive(:refresh_shipment_rates)
        attributes = { order_id: order.number, order: { email: "" } }
        put :update, params: attributes
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
          expect { put :update, params: attributes }.to change { order.reload.email }.to eq 'foo@bar.com'
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
            put :update, params: attributes
          }.to change{ order.reload.user }.to(assigned_user)
        end
      end

      context "not false guest checkout param" do
        it "does not attempt to associate the user" do
          allow(order).to receive_messages(update: true,
                                           next: false,
                                           refresh_shipment_rates: true)

          attributes = {
            order_id: order.number,
            order: { email: "foo@example.com" }
          }

          expect {
            put :update, params: attributes
          }.not_to change{ order.reload.user }
        end
      end
    end
  end
end
