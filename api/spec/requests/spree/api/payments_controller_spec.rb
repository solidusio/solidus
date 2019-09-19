# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Spree::Api::PaymentsController, type: :request do
    let!(:order) { create(:order) }
    let!(:payment) { create(:payment, order: order) }
    let!(:attributes) {
      [:id, :source_type, :source_id, :amount, :display_amount,
       :payment_method_id, :state, :avs_response,
       :created_at, :updated_at]
    }

    before do
      stub_authentication!
    end

    context "as a user" do
      context "when the order belongs to the user" do
        before do
          allow_any_instance_of(Order).to receive_messages user: current_api_user
        end

        it "can view the payments for their order" do
          get spree.api_order_payments_path(order)
          expect(json_response["payments"].first).to have_attributes(attributes)
        end

        it "can learn how to create a new payment" do
          get spree.new_api_order_payment_path(order)
          expect(json_response["attributes"]).to eq(attributes.map(&:to_s))
          expect(json_response["payment_methods"]).not_to be_empty
          expect(json_response["payment_methods"].first).to have_attributes([:id, :name, :description])
        end

        context "payment source is not required" do
          before do
            allow_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:source_required?).and_return(false)
          end

          it "can create a new payment" do
            post spree.api_order_payments_path(order), params: { payment: { payment_method_id: PaymentMethod.first.id, amount: 50 } }
            expect(response.status).to eq(201)
            expect(json_response).to have_attributes(attributes)
          end

          context "disallowed payment method" do
            it "does not create a new payment" do
              PaymentMethod.first.update!(available_to_users: false)

              expect {
                post spree.api_order_payments_path(order), params: { payment: { payment_method_id: PaymentMethod.first.id, amount: 50 } }
              }.not_to change { Spree::Payment.count }
              expect(response.status).to eq(404)
            end
          end
        end

        context "payment source is required" do
          context "no source is provided" do
            it "returns errors" do
              post spree.api_order_payments_path(order), params: { payment: { payment_method_id: PaymentMethod.first.id, amount: 50 } }
              expect(response.status).to eq(422)
              expect(json_response['error']).to eq("Invalid resource. Please fix errors and try again.")
              expect(json_response['errors']['source']).to eq(["can't be blank"])
            end
          end

          context "source is provided" do
            it "can create a new payment" do
              post spree.api_order_payments_path(order), params: { payment: { payment_method_id: PaymentMethod.first.id, amount: 50, source_attributes: { gateway_payment_profile_id: 1 } } }
              expect(response.status).to eq(201)
              expect(json_response).to have_attributes(attributes)
            end
          end
        end

        it "can view a pre-existing payment's details" do
          get spree.api_order_payment_path(order, payment)
          expect(json_response).to have_attributes(attributes)
        end

        it "cannot update a payment" do
          put spree.api_order_payment_path(order, payment), params: { payment: { amount: 2.01 } }
          assert_unauthorized!
        end

        it "cannot authorize a payment" do
          put spree.authorize_api_order_payment_path(order, payment)
          assert_unauthorized!
        end
      end

      context "when the order does not belong to the user" do
        before do
          allow_any_instance_of(Order).to receive_messages user: stub_model(LegacyUser)
        end

        it "cannot view payments for somebody else's order" do
          get spree.api_order_payments_path(order)
          assert_unauthorized!
        end

        it "can view the payments for an order given the order token" do
          get spree.api_order_payments_path(order), params: { order_token: order.guest_token }
          expect(json_response["payments"].first).to have_attributes(attributes)
        end
      end
    end

    context "as an admin" do
      sign_in_as_admin!

      it "can view the payments on any order" do
        get spree.api_order_payments_path(order)
        expect(response.status).to eq(200)
        expect(json_response["payments"].first).to have_attributes(attributes)
      end

      context "multiple payments" do
        before { @payment = create(:payment, order: order) }

        it "can view all payments on an order" do
          get spree.api_order_payments_path(order)
          expect(json_response["count"]).to eq(2)
        end

        it 'can control the page size through a parameter' do
          get spree.api_order_payments_path(order), params: { per_page: 1 }
          expect(json_response['count']).to eq(1)
          expect(json_response['current_page']).to eq(1)
          expect(json_response['pages']).to eq(2)
        end
      end

      context "for a given payment" do
        context "updating" do
          it "can update" do
            payment.update(state: 'pending')
            put spree.api_order_payment_path(order, payment), params: { payment: { amount: 2.01 } }
            expect(response.status).to eq(200)
            expect(payment.reload.amount).to eq(2.01)
          end

          context "update fails" do
            it "returns a 422 status when the amount is invalid" do
              payment.update(state: 'pending')
              put spree.api_order_payment_path(order, payment), params: { payment: { amount: 'invalid' } }
              expect(response.status).to eq(422)
              expect(json_response["error"]).to eq("Invalid resource. Please fix errors and try again.")
            end

            it "returns a 403 status when the payment is not pending" do
              payment.update(state: 'completed')
              put spree.api_order_payment_path(order, payment), params: { payment: { amount: 2.01 } }
              expect(response.status).to eq(403)
              expect(json_response["error"]).to eq("This payment cannot be updated because it is completed.")
            end
          end
        end

        context "authorizing" do
          it "can authorize" do
            put spree.authorize_api_order_payment_path(order, payment)
            expect(response.status).to eq(200)
            expect(payment.reload.state).to eq("pending")
          end

          context "authorization fails" do
            before do
              fake_response = double(success?: false, to_s: "Could not authorize card")
              expect_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:authorize).and_return(fake_response)
              put spree.authorize_api_order_payment_path(order, payment)
            end

            it "returns a 422 status" do
              expect(response.status).to eq(422)
              expect(json_response["error"]).to eq "Invalid resource. Please fix errors and try again."
              expect(json_response["errors"]["base"][0]).to eq "Could not authorize card"
            end

            it "does not raise a stack level error" do
              skip "Investigate why a payment.reload after the request raises 'stack level too deep'"
              expect(payment.reload.state).to eq("failed")
            end
          end
        end

        context "capturing" do
          it "can capture" do
            put spree.capture_api_order_payment_path(order, payment)
            expect(response.status).to eq(200)
            expect(payment.reload.state).to eq("completed")
          end

          context "capturing fails" do
            before do
              fake_response = double(success?: false, to_s: "Insufficient funds")
              expect_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:capture).and_return(fake_response)
            end

            it "returns a 422 status" do
              put spree.capture_api_order_payment_path(order, payment)
              expect(response.status).to eq(422)
              expect(json_response["error"]).to eq "Invalid resource. Please fix errors and try again."
              expect(json_response["errors"]["base"][0]).to eq "Insufficient funds"
            end
          end
        end

        context "purchasing" do
          it "can purchase" do
            put spree.purchase_api_order_payment_path(order, payment)
            expect(response.status).to eq(200)
            expect(payment.reload.state).to eq("completed")
          end

          context "purchasing fails" do
            before do
              fake_response = double(success?: false, to_s: "Insufficient funds")
              expect_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:purchase).and_return(fake_response)
            end

            it "returns a 422 status" do
              put spree.purchase_api_order_payment_path(order, payment)
              expect(response.status).to eq(422)
              expect(json_response["error"]).to eq "Invalid resource. Please fix errors and try again."
              expect(json_response["errors"]["base"][0]).to eq "Insufficient funds"
            end
          end
        end

        context "voiding" do
          it "can void" do
            put spree.void_api_order_payment_path(order, payment)
            expect(response.status).to eq 200
            expect(payment.reload.state).to eq "void"
          end

          context "voiding fails" do
            before do
              fake_response = double(success?: false, to_s: "NO REFUNDS")
              expect_any_instance_of(Spree::PaymentMethod::BogusCreditCard).to receive(:void).and_return(fake_response)
            end

            it "returns a 422 status" do
              put spree.void_api_order_payment_path(order, payment)
              expect(response.status).to eq 422
              expect(json_response["error"]).to eq "Invalid resource. Please fix errors and try again."
              expect(json_response["errors"]["base"][0]).to eq "NO REFUNDS"
              expect(payment.reload.state).to eq "checkout"
            end
          end
        end
      end
    end
  end
end
