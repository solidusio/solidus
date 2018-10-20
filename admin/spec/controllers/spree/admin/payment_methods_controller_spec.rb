# frozen_string_literal: true

require 'spec_helper'

module Spree
  class GatewayWithPassword < PaymentMethod
    preference :password, :string, default: "password"
  end

  describe Admin::PaymentMethodsController, type: :controller do
    stub_authorization!

    let(:payment_method) { GatewayWithPassword.create!(name: "Bogus", preferred_password: "haxme") }

    context "GatewayWithPassword" do
      before do
        allow(Rails.application.config.spree).to receive(:payment_methods).and_return([GatewayWithPassword])
      end

      # regression test for https://github.com/spree/spree/issues/2094
      it "does not clear password on update" do
        expect(payment_method.preferred_password).to eq("haxme")
        put :update, params: { id: payment_method.id, payment_method: { type: payment_method.class.to_s, preferred_password: "" } }
        expect(response).to redirect_to(spree.edit_admin_payment_method_path(payment_method))

        payment_method.reload
        expect(payment_method.preferred_password).to eq("haxme")
      end
    end

    context "tries to save invalid payment" do
      it "doesn't break, responds nicely" do
        post :create, params: { payment_method: { name: "", type: "Spree::PaymentMethod::BogusCreditCard" } }
      end
    end

    it "can create a payment method of a valid type" do
      expect {
        post :create, params: { payment_method: { name: "Test Method", type: "Spree::PaymentMethod::BogusCreditCard" } }
      }.to change(Spree::PaymentMethod, :count).by(1)

      expect(response).to be_redirect
      expect(response).to redirect_to spree.edit_admin_payment_method_path(assigns(:payment_method))
    end

    it "can not create a payment method of an invalid type" do
      expect {
        post :create, params: { payment_method: { name: "Invalid Payment Method", type: "Spree::InvalidType" } }
      }.to change(Spree::PaymentMethod, :count).by(0)

      expect(response).to be_redirect
      expect(response).to redirect_to spree.new_admin_payment_method_path
    end

    describe "#index" do
      subject { get :index }

      let!(:first_method) { GatewayWithPassword.create! name: "First", preferred_password: "1235" }
      let!(:second_method) { GatewayWithPassword.create! name: "Second", preferred_password: "1235" }

      before do
        second_method.move_to_top
      end

      it { is_expected.to be_successful }
      it { is_expected.to render_template "index"  }

      it "respects the order of payment methods by position" do
        subject
        expect(assigns(:payment_methods).to_a).to eql([second_method, first_method])
      end
    end

    describe "#update" do
      # Regression test for https://github.com/solidusio/solidus/issues/2789
      let(:params) do
        {
          id: payment_method.id,
          payment_method: {
            name: 'Check',
            type: 'Spree::PaymentMethod::Check'
          }
        }
      end

      it 'updates the resource' do
        put :update, params: params

        expect(response).to redirect_to(spree.edit_admin_payment_method_path(payment_method))
        response_payment_method = Spree::PaymentMethod.find(payment_method.id)
        expect(response_payment_method.name).to eql('Check')
      end
    end
  end
end
