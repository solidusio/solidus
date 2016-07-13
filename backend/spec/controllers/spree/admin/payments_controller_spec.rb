require 'spec_helper'

module Spree
  module Admin
    describe PaymentsController, type: :controller do
      before do
        allow(controller).to receive_messages spree_current_user: user
      end

      let(:user) { create(:admin_user) }
      let(:order) { create(:order) }

      describe '#create' do
        context "with a valid credit card" do
          let(:order) { create(:order_with_line_items, state: "payment") }
          let(:payment_method) { create(:credit_card_payment_method, display_on: "back_end") }
          let(:attributes) do
            {
              order_id: order.number,
              card: "new",
              payment: {
                amount: order.total,
                payment_method_id: payment_method.id.to_s,
                source_attributes: {
                  name: "Test User",
                  number: "4111 1111 1111 1111",
                  expiry: "09 / #{Time.current.year + 1}",
                verification_value: "123"
                }
              }
            }
          end

          before do
            post :create, attributes
          end

          it "should process payment correctly" do
            expect(order.payments.count).to eq(1)
            expect(order.payments.last.state).to eq 'checkout'
            expect(response).to redirect_to(spree.admin_order_payments_path(order))
            expect(order.reload.state).to eq('confirm')
          end

          context 'with credit card address fields' do
            let(:address) { build(:address) }

            let(:attributes) do
              attrs = super()
              attrs[:payment][:source_attributes][:address_attributes] = address_attributes
              attrs
            end

            let(:address_attributes) do
              {
                'firstname' => address.firstname,
                'lastname' => address.lastname,
                'address1' => address.address1,
                'city' => address.city,
                'country_id' => address.country_id,
                'state_id' => address.state_id,
                'zipcode' => address.zipcode,
                'phone' => address.phone
              }
            end

            it 'associates the address' do
              expect(order.payments.count).to eq(1)
              credit_card = order.payments.last.source
              expect(credit_card.address.attributes).to include(address_attributes)
            end
          end
        end
      end

      describe '#new' do
        # Regression test for https://github.com/spree/spree/issues/3233
        context "with a backend payment method" do
          before do
            @payment_method = create(:check_payment_method, display_on: "back_end")
          end

          it "loads backend payment methods" do
            get :new, order_id: order.number
            expect(response.status).to eq(200)
            expect(assigns[:payment_methods]).to include(@payment_method)
          end
        end
      end

      describe '#index' do
        context "order has billing address" do
          before do
            order.bill_address = create(:address)
            order.save!
          end

          context "order does not have payments" do
            it "redirect to new payments page" do
              get :index, { amount: 100, order_id: order.number }
              expect(response).to redirect_to(spree.new_admin_order_payment_path(order))
            end
          end

          context "order has payments" do
            before do
              order.payments << create(:payment, amount: order.total, order: order, state: 'completed')
            end

            it "shows the payments page" do
              get :index, { amount: 100, order_id: order.number }
              expect(response.code).to eq "200"
            end
          end
        end

        context "order does not have a billing address" do
          before do
            order.bill_address = nil
            order.save
          end

          it "should redirect to the customer details page" do
            get :index, { amount: 100, order_id: order.number }
            expect(response).to redirect_to(spree.edit_admin_order_customer_path(order))
          end
        end
      end

      describe '#fire' do
        describe 'authorization' do
          let(:payment) { create(:payment, state: 'checkout') }
          let(:order) { payment.order }

          context 'the user is authorized' do
            class CaptureAllowedAbility
              include CanCan::Ability

              def initialize(_user)
                can :capture, Spree::Payment
              end
            end

            before do
              Spree::Ability.register_ability(CaptureAllowedAbility)
            end

            it 'allows the action' do
              expect {
                post(:fire, id: payment.to_param, e: 'capture', order_id: order.to_param)
              }.to change { payment.reload.state }.from('checkout').to('completed')
            end

            context 'the user is not authorized' do
              class CaptureNotAllowedAbility
                include CanCan::Ability

                def initialize(_user)
                  cannot :capture, Spree::Payment
                end
              end

              before do
                Spree::Ability.register_ability(CaptureNotAllowedAbility)
              end

              it 'does not allow the action' do
                expect {
                  post(:fire, id: payment.to_param, e: 'capture', order_id: order.to_param)
                }.to_not change { payment.reload.state }
                expect(flash[:error]).to eq('Authorization Failure')
              end
            end
          end
        end
      end
    end
  end
end
