# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Checkouts', type: :request, with_signed_in_user: true do
  let(:user) { order.user }

  let(:address_params) do
    address = build(:address)
    address.attributes.except("created_at", "updated_at")
  end
  let(:order) { create(:order_with_line_items) }

  context "#edit" do
    let!(:order) { create(:order_with_line_items) }

    it 'checks if the user is authorized for :edit' do
      get checkout_path, params: { state: "address" }

      expect(assigns[:order]).to eq order
      expect(status).to eq(200)
    end

    it "redirects to the cart path if checkout_allowed? return false" do
      order.line_items.destroy_all
      get checkout_path, params: { state: "delivery" }

      expect(response).to redirect_to(cart_path)
    end

    it "redirects to the cart path if current_order is nil" do
      order.destroy
      get checkout_path, params: { state: "delivery" }

      expect(response).to redirect_to(cart_path)
    end

    it "redirects to cart if order is completed" do
      order.touch(:completed_at)
      get checkout_path, params: { state: "address" }

      expect(response).to redirect_to(cart_path)
    end

    # Regression test for https://github.com/spree/spree/issues/2280
    it "redirects to current step trying to access a future step" do
      order.update_column(:state, "address")

      get checkout_path, params: { state: "delivery" }
      expect(response).to redirect_to checkout_state_path("address")
    end
  end

  context "#update" do
    let!(:order) { create(:order_with_line_items) }

    it 'checks if the user is authorized for :edit' do
      expect do
        patch update_checkout_path(state: 'address', order: { bill_address_attributes: address_params })
      end.to change { order.reload.state }.from('cart').to('delivery')
    end

    context "save successful" do
      def post_address
        patch update_checkout_path(state: "address",
                                         order: {
                                           bill_address_attributes: address_params,
                                           use_billing: true
                                         })
      end

      let!(:payment_method) { create(:payment_method) }

      context "when the order in the cart state", partial_double_verification: false do
        let!(:order) { create(:order_with_line_items, state: 'cart') }

        it "assigns order" do
          patch update_checkout_path(state: 'address', order: { bill_address_attributes: address_params })
          expect(assigns[:order]).not_to be_nil
        end

        it "advances the state" do
          post_address
          expect(order.reload.state).to eq("delivery")
        end

        it "redirects the next state" do
          post_address
          expect(response).to redirect_to checkout_state_path("delivery")
        end

        context "current_user respond to save address method" do
          let(:order) { create(:order_with_line_items) }

          def post_persist_address
            patch update_checkout_path(state: "address",
                                             order: {
                                               bill_address_attributes: address_params,
                                               use_billing: true
                                             },
                                             save_user_address: "1")
          end

          it "calls persist order address on user" do
            user.user_addresses.destroy

            expect { post_persist_address }.to change { user.user_addresses.count }.from(0).to(1)
          end
        end
      end

      context "when the order in the address state" do
        context 'when landing to address page' do
          let!(:order) do
            create(:order_with_line_items, state: 'address', user_id: user.id, bill_address: nil, ship_address: nil)
          end
          let(:user) { create(:user_with_addresses) }
          let(:user_ship_address_attributes) { user.ship_address.attributes.except("created_at", "updated_at").compact }
          let(:user_bill_address_attributes) { user.bill_address.attributes.except("created_at", "updated_at").compact }
          let(:order_ship_address_attributes) { order.reload.ship_address.attributes.except("created_at", "updated_at").compact }
          let(:order_bill_address_attributes) { order.reload.bill_address.attributes.except("created_at", "updated_at").compact }

          it "tries to associate user addresses to order" do
            patch update_checkout_path(state: 'address', order: { email: 'test@email.com' })

            expect(order_ship_address_attributes).to eq user_ship_address_attributes
            expect(order_bill_address_attributes).to eq user_bill_address_attributes
          end
        end

        context "when a billing and shipping address" do
          subject do
            patch update_checkout_path(
              state: 'address',
              order: {
                bill_address_attributes: order.bill_address.attributes.except("created_at", "updated_at").compact,
                ship_address_attributes: order.ship_address.attributes.except("created_at", "updated_at").compact,
                use_billing: false
              }
            )
          end

          it "doesn't change bill address" do
            expect do
              subject
            end.not_to(change { order.reload.ship_address.id })
          end

          it "doesn't change ship address" do
            expect do
              subject
            end.not_to(change { order.reload.bill_address.id })
          end
        end
      end

      # This is the only time that we need the 'set_payment_parameters_amount'
      # controller code, because otherwise the transition to 'confirm' will
      # trigger the 'add_store_credit_payments' transition code which will do
      # the same thing here.
      # Perhaps we can just remove 'set_payment_parameters_amount' entirely at
      # some point?
      context "when there is a checkout step between payment and confirm", partial_double_verification: false do
        before do
          @old_checkout_flow = Spree::Order.checkout_flow
          Spree::Order.class_eval do
            insert_checkout_step :new_step, after: :payment
          end
        end

        after do
          Spree::Order.checkout_flow(&@old_checkout_flow)
        end

        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:payment_method) { create(:credit_card_payment_method) }

        let(:params) do
          {
            state: 'payment',
            order: {
              payments_attributes: [
                {
                  payment_method_id: payment_method.id.to_s,
                  source_attributes: attributes_for(:credit_card)
                }
              ]
            }
          }
        end

        it 'sets the payment amount' do
          patch update_checkout_path(params)
          order.reload
          expect(order.state).to eq('new_step')
          expect(order.payments.size).to eq(1)
          expect(order.payments.first.amount).to eq(order.total)
        end
      end

      context "when in the payment state" do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:payment_method) { create(:credit_card_payment_method) }

        let(:params) do
          {
            state: 'payment',
            order: {
              payments_attributes: [
                {
                  payment_method_id: payment_method.id.to_s,
                  source_attributes: attributes_for(:credit_card)
                }
              ]
            }
          }
        end

        context 'when a permitted payment method' do
          it 'sets the payment amount' do
            patch update_checkout_path(params)
            order.reload
            expect(order.state).to eq('confirm')
            expect(order.payments.size).to eq(1)
            expect(order.payments.first.amount).to eq(order.total)
          end
        end

        context 'when an unpermitted payment method' do
          before { payment_method.update!(available_to_users: false) }

          it 'sets the payment amount' do
            patch update_checkout_path(params)

            expect(response.status).to eq(404)
            expect(order.state).to eq('payment')
            expect(order.payments).to be_empty
          end
        end

        context 'trying to change the address' do
          let(:params) do
            {
              order: {
                payments_attributes: [
                  {
                    payment_method_id: payment_method.id.to_s,
                    source_attributes: attributes_for(:credit_card)
                  }
                ],
                ship_address_attributes: {
                  zipcode: 'TEST'
                }
              }
            }
          end

          it 'does not change the address' do
            expect do
              patch update_checkout_path(state: 'payment', params: params)
            end.not_to(change { order.reload.ship_address.zipcode })
          end
        end
      end

      context "when in the confirm state" do
        let(:order) { create(:order_with_line_items, state: 'confirm') }

        before do
          # An order requires a payment to reach the complete state
          # This is because payment_required? is true on the order
          create(:payment, amount: order.total, order: order)
          order.create_proposed_shipments
          order.payments.reload
          order.save
        end

        # This inadvertently is a regression test for https://github.com/spree/spree/issues/2694
        it "redirects to the order view" do
          patch update_checkout_path(state: "confirm")
          expect(response).to redirect_to order_path(order)
        end

        it "populates the flash message" do
          patch update_checkout_path(state: "confirm")
          expect(flash.notice).to eq(I18n.t('spree.order_processed_successfully'))
        end

        it "removes completed order from current_order" do
          patch update_checkout_path(state: "confirm")
          expect(assigns(:current_order)).to be_nil
          expect(assigns(:order)).to eql order
        end
      end
    end

    context "save unsuccessful" do
      it "does not assign order" do
        patch update_checkout_path(state: "address", order: { bill_address_attributes: address_params })
        expect(assigns[:order]).not_to be_nil
      end

      it "renders the edit template" do
        order.line_items.destroy_all
        patch update_checkout_path(state: "address", order: { bill_address_attributes: address_params })
        expect(response).to redirect_to(cart_path)
      end
    end

    context "when current_order id nil" do
      let(:user) { create(:user) }
      let(:order) { create(:order_with_line_items, guest_token: nil, user_id: nil) }

      it "redirects to the cart_path" do
        patch update_checkout_path(state: "confirm")
        expect(response).to redirect_to cart_path
      end
    end

    context "Spree::Core::GatewayError" do
      let(:order) { create(:order_ready_to_complete) }
      let(:payment) { order.payments.first }
      let(:updater_instance) { instance_double(Spree::OrderUpdater) }

      before do
        allow(Spree::OrderUpdater).to receive(:new).and_return(updater_instance)
        allow(updater_instance).to receive(:recalculate_payment_state).and_raise(Spree::Core::GatewayError.new('Invalid something or other.'))
        patch update_checkout_path(state: order.state, order: { bill_address_attributes: address_params })
      end

      it "renders the edit template and display exception message" do
        expect(response).to render_template :edit
        expect(flash.now[:error]).to eq(I18n.t('spree.spree_gateway_error_flash_for_checkout'))
        expect(assigns(:order).errors[:base]).to include("Invalid something or other.")
      end
    end

    context "fails to transition from address" do
      context "when the order is invalid" do
        let(:order_update_attributes) { instance_double(Spree::OrderUpdateAttributes, apply: true) }

        before do
          order.update(state: 'address', ship_address: nil, bill_address: nil)
          allow(Spree::OrderUpdateAttributes).to receive(:new) { order_update_attributes }
        end

        it "due to the order having errors" do
          patch update_checkout_path(state: order.state, order: { bill_address_attributes: address_params })
          expect(flash[:error]).to eq("Valid shipping address required")
          expect(response).to redirect_to(checkout_state_path('address'))
        end
      end

      context "when the country is not a shippable country" do
        let(:foreign_address) { create(:address, country_iso_code: "CA") }

        before do
          order.update(shipping_address: foreign_address)
        end

        it "redirects due to no available shipping rates for any of the shipments" do
          patch update_checkout_path(state: "address", order: { bill_address_attributes: address_params })
          expect(request.flash.to_h['error']).to eq(I18n.t('spree.items_cannot_be_shipped'))
          expect(response).to redirect_to(checkout_state_path('address'))
        end
      end
    end

    context "when GatewayError is raised" do
      let(:order) { create(:order_ready_to_complete) }
      let(:payment_source) { order.payments.first.source }

      before { payment_source.destroy! }

      it "fails to transition from payment to complete" do
        patch update_checkout_path(state: order.state, order: {})
        expect(flash[:error]).to eq(I18n.t('spree.payment_processing_failed'))
      end
    end

    context "when InsufficientStock error is raised" do
      context "when the order has no shipments" do
        let(:order) { create(:order_with_line_items, state: 'address') }
        let(:quantifier_instance) { instance_double(Spree::Stock::Quantifier, can_supply?: true) }

        before do
          allow(Spree::OrderUpdateAttributes).to receive(:new).and_raise(Spree::Order::InsufficientStock)
          allow(Spree::Stock::Quantifier).to receive(:new).and_return(quantifier_instance)
          order.shipments.destroy_all
        end

        it "redirects the customer to the cart page with an error message" do
          patch update_checkout_path(state: "address", order: { bill_address_attributes: address_params })
          expect(flash[:error]).to eq(I18n.t('spree.insufficient_stock_for_order'))
          expect(response).to redirect_to(cart_path)
        end
      end

      context "when the order has shipments" do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:availability_validator) { instance_double(Spree::Stock::AvailabilityValidator) }

        context "when items become somehow not available anymore" do
          before do
            allow(Spree::OrderUpdateAttributes).to receive(:new).and_raise(Spree::Order::InsufficientStock)
            allow(Spree::Stock::AvailabilityValidator).to receive(:new) { availability_validator }
            allow(availability_validator).to receive(:validate).and_return(false)
          end

          it "redirects the customer to the address checkout page with an error message" do
            patch update_checkout_path(state: "address", order: { bill_address_attributes: address_params })
            error = I18n.t('spree.inventory_error_flash_for_insufficient_shipment_quantity', unavailable_items: order.products.first.name)
            expect(flash[:error]).to eq(error)
            expect(response).to redirect_to(checkout_state_path(state: :address))
          end
        end
      end
    end
  end

  context "When last inventory item has been purchased" do
    let(:order) { create(:order_with_line_items) }

    before do
      stub_spree_preferences(track_inventory_levels: true)
    end

    context "when back orders are not allowed" do
      before do
        order
        Spree::StockItem.update_all(count_on_hand: 0, backorderable: false)
        patch update_checkout_path(state: "payment")
      end

      it "redirects to cart" do
        expect(response).to redirect_to cart_path
      end

      it "redirects set flash message for no inventory" do
        expect(flash[:error]).to eq("#{order.line_items.first.name} became unavailable.")
      end
    end
  end

  context "when order doesn't have a delivery step" do
    let(:order) { create(:order_with_line_items, ship_address: nil, state: 'address') }

    before do
      @old_checkout_flow = Spree::Order.checkout_flow
      Spree::Order.class_eval do
        remove_checkout_step :delivery
      end
    end

    after do
      Spree::Order.checkout_flow(&@old_checkout_flow)
    end

    it "doesn't set a default shipping address on the order" do
      get checkout_path, params: { state: order.state, order: { bill_address_attributes: address_params } }
      expect(assigns[:order].ship_address).to be_nil
    end

    it "doesn't remove unshippable items before payment" do
      expect do
        patch update_checkout_path(state: "payment")
      end.to_not(change { order.line_items })
    end
  end

  context 'when there are line items not shippable' do
    let(:order) { create(:order_with_line_items, state: 'payment') }
    let(:differentiator) { instance_double(Spree::Stock::Differentiator, missing: { order.variants.first => 1 }) }

    before do
      allow(Spree::Stock::Differentiator).to receive(:new) { differentiator }
    end

    it "removes unshippable items before payment" do
      expect do
        patch update_checkout_path(state: "payment", order: { email: "johndoe@example.com" })
      end.to change { order.line_items.reload.to_a.size }.from(1).to(0)
    end
  end
end
