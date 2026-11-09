# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/testing_support/shared_examples/moveable"
require "solidus_admin/testing_support/shared_examples/crud_resource_requests"

RSpec.describe "SolidusAdmin::PaymentMethodsController", type: :request do
  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?).and_return(true)
  end

  it_behaves_like "requests: moveable" do
    let(:factory) { :payment_method }
    let(:request_path) { solidus_admin.move_payment_method_path(record, format: :js) }
  end

  include_examples "CRUD resource requests", "payment_method" do
    let(:resource_class) { Spree::PaymentMethod }
    let(:valid_attributes) { {name: "Credit Card", type: "Spree::PaymentMethod::BogusCreditCard"} }
    let(:invalid_attributes) { {name: "", type: ""} }

    describe "POST /create" do
      context "with an invalid type" do
        let(:invalid_attributes) { {name: "Invalid Payment Method", type: "Spree::InvalidType"} }

        it "does not create a payment method" do
          expect {
            post solidus_admin.payment_methods_path, params: {payment_method: invalid_attributes}
          }.not_to change(Spree::PaymentMethod, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with a type and and type-specific preferences" do
        let(:valid_attributes) {
          {
            name: "Valid Payment Method",
            type: "Spree::PaymentMethod::BogusCreditCard",
            preferred_bogus_string: "bogus-string-setting"
          }
        }

        it "creates a payment method with the given settings" do
          expect {
            post solidus_admin.payment_methods_path,
              params: {payment_method: valid_attributes}
          }.to change(Spree::PaymentMethod, :count)

          record = Spree::PaymentMethod.last

          expect(record.type).to eq "Spree::PaymentMethod::BogusCreditCard"
          expect(record.options[:bogus_string]).to eq "bogus-string-setting"
        end
      end
    end

    describe "PUT /update" do
      context "with an invalid type" do
        let(:invalid_attributes) { {type: "Spree::InvalidType"} }

        it "does not update the payment method" do
          expect {
            put solidus_admin.payment_method_path(resource), params: {payment_method: invalid_attributes}
          }.not_to change { resource.reload.name }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "when updating a payment method's type" do
        let(:factory) { :check_payment_method }
        let(:valid_attributes) {
          {
            type: "Spree::PaymentMethod::BogusCreditCard",
            preferred_bogus_string: "new-value"
          }
        }

        it "updates the payment method type and its type-specific preferences" do
          expect {
            put solidus_admin.payment_method_path(resource),
              params: {payment_method: valid_attributes}
          }
            .to change { Spree::PaymentMethod.find(resource.id).type }
            .from("Spree::PaymentMethod::Check")
            .to("Spree::PaymentMethod::BogusCreditCard")

          record = Spree::PaymentMethod.last

          expect(record.options[:bogus_string]).to eq "new-value"
        end
      end
    end
  end
end
