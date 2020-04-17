# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Api::CheckoutsController, type: :request do
    before(:each) do
      stub_authentication!
      stub_spree_preferences(track_inventory_levels: false)
      country_zone = create(:zone, name: 'CountryZone')
      @state = create(:state)
      @country = @state.country
      country_zone.members.create(zoneable: @country)
      create(:stock_location)

      @shipping_method = create(:shipping_method, zones: [country_zone])
      @payment_method = create(:credit_card_payment_method)
    end

    context "PUT 'update'" do
      let(:order) do
        order = create(:order_with_line_items)
        # Order should be in a pristine state
        # Without doing this, the order may transition from 'cart' straight to 'delivery'
        order.shipments.delete_all
        order
      end

      before(:each) do
        allow_any_instance_of(Order).to receive_messages(payment_required?: true)
      end

      it "should transition a recently created order from cart to address" do
        expect(order.state).to eq "cart"
        expect(order.email).not_to be_nil
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token }
        expect(order.reload.state).to eq "address"
      end

      it "should transition a recently created order from cart to address with order token in header" do
        expect(order.state).to eq "cart"
        expect(order.email).not_to be_nil
        put spree.api_checkout_path(order), headers: { "X-Spree-Order-Token" => order.guest_token }
        expect(order.reload.state).to eq "address"
      end

      it "can take line_items_attributes as a parameter" do
        line_item = order.line_items.first
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { line_items_attributes: { 0 => { id: line_item.id, quantity: 1 } } } }
        expect(response.status).to eq(200)
        expect(order.reload.state).to eq "address"
      end

      it "can take line_items as a parameter" do
        line_item = order.line_items.first
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { line_items: { 0 => { id: line_item.id, quantity: 1 } } } }
        expect(response.status).to eq(200)
        expect(order.reload.state).to eq "address"
      end

      it "will return an error if the order cannot transition" do
        order.update!(state: 'address', ship_address: nil)
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token }
        expect(response.status).to eq(422)
      end

      context "transitioning to delivery" do
        before do
          order.update_column(:state, "address")
        end

        let(:address) do
          {
            name:  'John Doe',
            address1:   '7735 Old Georgetown Road',
            city:       'Bethesda',
            phone:      '3014445002',
            zipcode:    '20814',
            state_id:   @state.id,
            country_id: @country.id
          }
        end

        it "can update addresses and transition from address to delivery" do
          put spree.api_checkout_path(order),
            params: { order_token: order.guest_token, order: {
              bill_address_attributes: address,
              ship_address_attributes: address
            } }
          expect(json_response['state']).to eq('delivery')
          expect(json_response['bill_address']['name']).to eq('John Doe')
          expect(json_response['ship_address']['name']).to eq('John Doe')
          expect(response.status).to eq(200)
        end

        # Regression Spec for https://github.com/spree/spree/issues/5389 and https://github.com/spree/spree/issues/5880
        it "can update addresses but not transition to delivery w/o shipping setup" do
          Spree::ShippingMethod.all.each(&:really_destroy!)
          put spree.api_checkout_path(order),
            params: { order_token: order.guest_token, order: {
              bill_address_attributes: address,
              ship_address_attributes: address
            } }
          expect(json_response['error']).to eq(I18n.t(:could_not_transition, scope: "spree.api.order"))
          expect(response.status).to eq(422)
        end

        # Regression test for https://github.com/spree/spree/issues/4498
        it "does not contain duplicate variant data in delivery return" do
          put spree.api_checkout_path(order),
            params: { order_token: order.guest_token, order: {
              bill_address_attributes: address,
              ship_address_attributes: address
            } }
          # Shipments manifests should not return the ENTIRE variant
          # This information is already present within the order's line items
          expect(json_response['shipments'].first['manifest'].first['variant']).to be_nil
          expect(json_response['shipments'].first['manifest'].first['variant_id']).to_not be_nil
        end
      end

      it "can update shipping method and transition from delivery to payment" do
        order.update_column(:state, "delivery")
        shipment = create(:shipment, order: order)
        shipment.refresh_rates
        shipping_rate = shipment.shipping_rates.where(selected: false).first
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { shipments_attributes: { "0" => { selected_shipping_rate_id: shipping_rate.id, id: shipment.id } } } }
        expect(response.status).to eq(200)
        # Find the correct shipment...
        json_shipment = json_response['shipments'].detect { |value| value["id"] == shipment.id }
        # Find the correct shipping rate for that shipment...
        json_shipping_rate = json_shipment['shipping_rates'].detect { |value| value["id"] == shipping_rate.id }
        # ... And finally ensure that it's selected
        expect(json_shipping_rate['selected']).to be true
        # Order should automatically transfer to payment because all criteria are met
        expect(json_response['state']).to eq('payment')
      end

      it "can update payment method and transition from payment to confirm" do
        order.update_column(:state, "payment")
        allow_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:source_required?).and_return(false)
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { payments_attributes: [{ payment_method_id: @payment_method.id }] } }
        expect(json_response['state']).to eq('confirm')
        expect(json_response['payments'][0]['payment_method']['name']).to eq(@payment_method.name)
        expect(json_response['payments'][0]['amount']).to eq(order.total.to_s)
        expect(response.status).to eq(200)
      end

      context "with disallowed payment method" do
        it "returns not found" do
          order.update_column(:state, "payment")
          allow_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:source_required?).and_return(false)
          @payment_method.update!(available_to_users: false)
          expect {
            put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { payments_attributes: [{ payment_method_id: @payment_method.id }] } }
          }.not_to change { Spree::Payment.count }
          expect(response.status).to eq(404)
        end
      end

      it "returns errors when source is required and missing" do
        order.update_column(:state, "payment")
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { payments_attributes: [{ payment_method_id: @payment_method.id }] } }
        expect(response.status).to eq(422)
        source_errors = json_response['errors']['payments.source']
        expect(source_errors).to include("can't be blank")
      end

      describe 'setting the payment amount' do
        let(:params) do
          {
            order_token: order.guest_token,
            order: {
              payments_attributes: [
                {
                  payment_method_id: @payment_method.id.to_s,
                  source_attributes: attributes_for(:credit_card)
                }
              ]
            }
          }
        end

        it 'sets the payment amount to the order total' do
          put spree.api_checkout_path(order), params: params
          expect(response.status).to eq(200)
          expect(json_response['payments'][0]['amount']).to eq(order.total.to_s)
        end
      end

      describe 'payment method with source and transition from payment to confirm' do
        before do
          order.update_column(:state, "payment")
        end

        let(:params) do
          {
            order_token: order.guest_token,
            order: {
              payments_attributes: [
                {
                  payment_method_id: @payment_method.id.to_s,
                  source_attributes: attributes_for(:credit_card)
                }
              ]
            }
          }
        end

        it 'succeeds' do
          put spree.api_checkout_path(order), params: params
          expect(response.status).to eq(200)
          expect(json_response['payments'][0]['payment_method']['name']).to eq(@payment_method.name)
          expect(json_response['payments'][0]['amount']).to eq(order.total.to_s)
        end
      end

      context 'when source is missing attributes' do
        before do
          order.update_column(:state, "payment")
        end

        let(:params) do
          {
            order_token: order.guest_token,
            order: {
              payments_attributes: [
                {
                  payment_method_id: @payment_method.id.to_s,
                  source_attributes: { name: "Spree" }
                }
              ]
            }
          }
        end

        it 'returns errors' do
          put spree.api_checkout_path(order), params: params

          expect(response.status).to eq(422)
          cc_errors = json_response['errors']['payments.Credit Card']
          expect(cc_errors).to include("Card Number can't be blank")
          expect(cc_errors).to include("Month is not a number")
          expect(cc_errors).to include("Year is not a number")
          expect(cc_errors).to include("Verification Value can't be blank")
        end
      end

      context 'reusing a credit card' do
        before do
          order.update_column(:state, "payment")
        end

        let(:params) do
          {
            order_token: order.guest_token,
            order: {
              payments_attributes: [
                {
                  source_attributes: {
                    wallet_payment_source_id: wallet_payment_source.id.to_param,
                    verification_value: '456'
                  }
                }
              ]
            }
          }
        end

        let!(:wallet_payment_source) do
          order.user.wallet.add(credit_card)
        end

        let(:credit_card) do
          create(:credit_card, user_id: order.user_id, payment_method_id: @payment_method.id)
        end

        it 'succeeds' do
          # unfortunately the credit card gets reloaded by `@order.next` before
          # the controller action finishes so this is the best way I could think
          # of to test that the verification_value gets set.
          expect_any_instance_of(Spree::CreditCard).to(
            receive(:verification_value=).with('456').and_call_original
          )

          put spree.api_checkout_path(order), params: params

          expect(response.status).to eq 200
          expect(order.credit_cards).to match_array [credit_card]
        end

        context 'with deprecated existing_card_id param' do
          let(:params) do
            {
              order_token: order.guest_token,
              order: {
                payments_attributes: [
                  {
                    source_attributes: {
                      existing_card_id: credit_card.id.to_param,
                      verification_value: '456'
                    }
                  }
                ]
              }
            }
          end

          it 'succeeds' do
            Spree::Deprecation.silence do
              put spree.api_checkout_path(order), params: params
            end

            expect(response.status).to eq 200
            expect(order.credit_cards).to match_array [credit_card]
          end
        end
      end

      it "returns the order if the order is already complete" do
        order.update_columns(completed_at: Time.current, state: 'complete')
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token }
        assert_unauthorized!
      end

      # Regression test for https://github.com/spree/spree/issues/3784
      it "can update the special instructions for an order" do
        instructions = "Don't drop it. (Please)"
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { special_instructions: instructions } }
        expect(json_response['special_instructions']).to eql(instructions)
      end

      context "as an admin" do
        sign_in_as_admin!
        it "can assign a user to the order" do
          user = create(:user)
          # Need to pass email as well so that validations succeed
          put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { user_id: user.id, email: "guest@spreecommerce.com" } }
          expect(response.status).to eq(200)
          expect(json_response['user_id']).to eq(user.id)
        end
      end

      it "can assign an email to the order" do
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { email: "guest@spreecommerce.com" } }
        expect(json_response['email']).to eq("guest@spreecommerce.com")
        expect(response.status).to eq(200)
      end

      it "can apply a coupon code to an order" do
        expect(Spree::Deprecation).to receive(:warn)
        order.update_column(:state, "payment")
        expect(PromotionHandler::Coupon).to receive(:new).with(order).and_call_original
        expect_any_instance_of(PromotionHandler::Coupon).to receive(:apply).and_return({ coupon_applied?: true })
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { coupon_code: "foobar" } }
        expect(response.status).to eq(200)
      end

      it "renders error failing to apply coupon" do
        expect(Spree::Deprecation).to receive(:warn)
        order.update_column(:state, "payment")
        put spree.api_checkout_path(order.to_param), params: { order_token: order.guest_token, order: { coupon_code: "foobar" } }
        expect(response.status).to eq(422)
        expect(json_response).to eq({ "error" => "The coupon code you entered doesn't exist. Please try again." })
      end
    end

    context "PUT 'next'" do
      let!(:order) { create(:order_with_line_items) }
      it "cannot transition to address without a line item" do
        order.line_items.delete_all
        order.update_column(:email, "spree@example.com")
        put spree.next_api_checkout_path(order), params: { order_token: order.guest_token }
        expect(response.status).to eq(422)
        expect(json_response["errors"]["base"]).to include(I18n.t('spree.there_are_no_items_for_this_order'))
      end

      it "can transition an order to the next state" do
        order.update_column(:email, "spree@example.com")

        put spree.next_api_checkout_path(order), params: { order_token: order.guest_token }
        expect(response.status).to eq(200)
        expect(json_response['state']).to eq('address')
      end

      it "cannot transition if order email is blank" do
        order.update_columns(
          state: 'address',
          email: nil
        )

        put spree.next_api_checkout_path(order), params: { id: order.to_param, order_token: order.guest_token }
        expect(response.status).to eq(422)
        expect(json_response['error']).to match(/could not be transitioned/)
      end
    end

    context "complete" do
      context "with order in confirm state" do
        subject do
          put spree.complete_api_checkout_path(order), params: params
        end

        let(:params) { { order_token: order.guest_token } }
        let(:order) { create(:order_with_line_items) }

        before do
          order.update_column(:state, "confirm")
        end

        it "can transition from confirm to complete" do
          allow_any_instance_of(Spree::Order).to receive_messages(payment_required?: false)
          subject
          expect(json_response['state']).to eq('complete')
          expect(response.status).to eq(200)
        end

        it "returns a sensible error when no payment method is specified" do
          # put :complete, id: order.to_param, order_token: order.token, order: {}
          subject
          expect(json_response["errors"]["base"]).to include(I18n.t('spree.no_payment_found'))
        end

        context "with mismatched expected_total" do
          let(:params) { super().merge(expected_total: order.total + 1) }

          it "returns an error if expected_total is present and does not match actual total" do
            # put :complete, id: order.to_param, order_token: order.token, expected_total: order.total + 1
            subject
            expect(response.status).to eq(400)
            expect(json_response['errors']['expected_total']).to include(I18n.t('spree.api.order.expected_total_mismatch'))
          end
        end
      end
    end

    context "PUT 'advance'" do
      let!(:order) { create(:order_with_line_items) }

      it 'continues to advance an order while it can move forward' do
        expect_any_instance_of(Spree::Order).to receive(:next).exactly(3).times.and_return(true, true, false)
        put spree.advance_api_checkout_path(order), params: { order_token: order.guest_token }
      end

      it 'returns the order' do
        put spree.advance_api_checkout_path(order), params: { order_token: order.guest_token }
        expect(json_response['id']).to eq(order.id)
      end
    end
  end
end
