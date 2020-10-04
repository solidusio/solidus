# frozen_string_literal: true

require 'spec_helper'

describe Spree::OrdersController, type: :controller do
  let!(:store) { create(:store) }
  let(:user) { create(:user) }

  context "Order model mock" do
    let(:order) do
      Spree::Order.create!
    end
    let(:variant) { create(:variant) }

    before do
      allow(controller).to receive_messages(try_spree_current_user: user)
    end

    context "#populate" do
      it "should create a new order when none specified" do
        post :populate, params: { variant_id: variant.id }
        expect(response).to be_redirect
        expect(cookies.signed[:guest_token]).not_to be_blank

        order_by_token = Spree::Order.find_by(guest_token: cookies.signed[:guest_token])
        assigned_order = assigns[:order]

        expect(assigned_order).to eq order_by_token
        expect(assigned_order).to be_persisted
      end

      context "with Variant" do
        it "should handle population" do
          expect do
            post :populate, params: { variant_id: variant.id, quantity: 5 }
          end.to change { user.orders.count }.by(1)
          order = user.orders.last
          expect(response).to redirect_to spree.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(5)
        end

        it "shows an error when population fails" do
          request.env["HTTP_REFERER"] = spree.root_path
          allow_any_instance_of(Spree::LineItem).to(
            receive(:valid?).and_return(false)
          )
          allow_any_instance_of(Spree::LineItem).to(
            receive_message_chain(:errors, :full_messages).
              and_return(["Order population failed"])
          )

          post :populate, params: { variant_id: variant.id, quantity: 5 }

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq("Order population failed")
        end

        it "shows an error when quantity is invalid" do
          request.env["HTTP_REFERER"] = spree.root_path

          post(
            :populate,
            params: { variant_id: variant.id, quantity: -1 }
          )

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq(
            I18n.t('spree.please_enter_reasonable_quantity')
          )
        end

        context "when quantity is empty string" do
          it "should populate order with 1 of given variant" do
            expect do
              post :populate, params: { variant_id: variant.id, quantity: '' }
            end.to change { Spree::Order.count }.by(1)
            order = Spree::Order.last
            expect(response).to redirect_to spree.cart_path
            expect(order.line_items.size).to eq(1)
            line_item = order.line_items.first
            expect(line_item.variant_id).to eq(variant.id)
            expect(line_item.quantity).to eq(1)
          end
        end

        context "when quantity is nil" do
          it "should populate order with 1 of given variant" do
            expect do
              post :populate, params: { variant_id: variant.id, quantity: nil }
            end.to change { Spree::Order.count }.by(1)
            order = Spree::Order.last
            expect(response).to redirect_to spree.cart_path
            expect(order.line_items.size).to eq(1)
            line_item = order.line_items.first
            expect(line_item.variant_id).to eq(variant.id)
            expect(line_item.quantity).to eq(1)
          end
        end
      end
    end

    context '#edit' do
      before do
        allow(controller).to receive :authorize!
        allow(controller).to receive_messages current_order: order
      end

      it 'should render cart' do
        get :edit, params: { id: order.number }

        expect(flash[:error]).to be_nil
        expect(response).to be_ok
      end

      context 'with another order number than the current_order' do
        let(:other_order) { create(:completed_order_with_totals) }

        it 'should display error message' do
          get :edit, params: { id: other_order.number }

          expect(flash[:error]).to eq "You may only edit your current shopping cart."
          expect(response).to redirect_to cart_path
        end
      end
    end

    context "#update" do
      context "with authorization" do
        before do
          allow(controller).to receive :authorize!
          allow(controller).to receive_messages current_order: order
        end

        it "should render the edit view (on failure)" do
          # email validation is only after address state
          order.update_column(:state, "delivery")
          put :update, params: { order: { email: "" } }
          expect(response).to render_template :edit
        end

        it "should redirect to cart path (on success)" do
          allow(order).to receive(:update).and_return true
          put :update
          expect(response).to redirect_to(spree.cart_path)
        end

        it "should advance the order if :checkout button is pressed" do
          allow(order).to receive(:update).and_return true
          expect(order).to receive(:next)
          put :update, params: { checkout: true }
          expect(response).to redirect_to checkout_state_path('address')
        end

        context 'trying to apply a coupon code' do
          let(:order) { create(:order_with_line_items, state: 'cart') }
          let(:coupon_code) { "coupon_code" }

          context "when coupon code is empty" do
            let(:coupon_code) { "" }

            it 'does not try to apply coupon code' do
              expect(Spree::PromotionHandler::Coupon).not_to receive :new

              put :update, params: { state: order.state, order: { coupon_code: coupon_code } }

              expect(response).to redirect_to(spree.cart_path)
            end
          end

          context "when coupon code is applied" do
            let(:promotion_handler) { instance_double('Spree::PromotionHandler::Coupon', error: nil, success: 'Coupon Applied!') }

            it "continues checkout flow normally" do
              expect(Spree::Deprecation).to receive(:warn)

              expect(Spree::PromotionHandler::Coupon)
                .to receive_message_chain(:new, :apply)
                .and_return(promotion_handler)

              put :update, params: { state: order.state, order: { coupon_code: coupon_code } }

              expect(response).to redirect_to(spree.cart_path)
              expect(flash.now[:success]).to eq('Coupon Applied!')
            end

            context "when coupon code is not applied" do
              let(:promotion_handler) { instance_double('Spree::PromotionHandler::Coupon', error: 'Some error', success: false) }

              it "render cart with coupon error" do
                expect(Spree::Deprecation).to receive(:warn)

                expect(Spree::PromotionHandler::Coupon)
                  .to receive_message_chain(:new, :apply)
                  .and_return(promotion_handler)

                put :update, params: { state: order.state, order: { coupon_code: coupon_code } }

                expect(response).to render_template :edit
                expect(flash.now[:error]).to eq('Some error')
              end
            end
          end
        end
      end
    end

    context "#empty" do
      before do
        allow(controller).to receive :authorize!
      end

      it "should destroy line items in the current order" do
        allow(controller).to receive(:current_order).and_return(order)
        expect(order).to receive(:empty!)
        put :empty
        expect(response).to redirect_to(spree.cart_path)
      end
    end

    # Regression test for https://github.com/spree/spree/issues/2750
    context "#update" do
      before do
        allow(user).to receive :last_incomplete_spree_order
        allow(controller).to receive :set_current_order
      end

      it "cannot update a blank order" do
        put :update, params: { order: { email: "foo" } }
        expect(flash[:error]).to eq(I18n.t('spree.order_not_found'))
        expect(response).to redirect_to(spree.root_path)
      end
    end
  end

  context "line items quantity is 0" do
    let(:order) { Spree::Order.create(store: store) }
    let(:variant) { create(:variant) }
    let!(:line_item) { order.contents.add(variant, 1) }

    before do
      allow(controller).to receive :authorize!
      allow(controller).to receive_messages(current_order: order)
    end

    it "removes line items on update" do
      expect(order.line_items.count).to eq 1
      put :update, params: { order: { line_items_attributes: { "0" => { id: line_item.id, quantity: 0 } } } }
      expect(order.reload.line_items.count).to eq 0
    end
  end

  describe '#edit' do
    subject { get :edit }
    let(:user) { build :user }

    it "builds a new valid order with complete meta-data" do
      allow(controller).to receive_messages(try_spree_current_user: user)

      subject

      order = controller.instance_variable_get(:@order)

      aggregate_failures do
        expect(order).to be_valid
        expect(order).not_to be_persisted
        expect(order.store).to be_present
        expect(order.user).to eq(user)
        expect(order.created_by).to eq(user)
      end
    end
  end
end
