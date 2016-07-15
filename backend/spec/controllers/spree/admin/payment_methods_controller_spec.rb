require 'spec_helper'

module Spree
  class GatewayWithPassword < PaymentMethod
    preference :password, :string, default: "password"
  end

  describe Admin::PaymentMethodsController, type: :controller do
    stub_authorization!

    context "GatewayWithPassword" do
      let(:payment_method) { GatewayWithPassword.create!(name: "Bogus", preferred_password: "haxme") }

      before do
        allow(Rails.application.config.spree).to receive(:payment_methods).and_return([GatewayWithPassword])
      end

      # regression test for https://github.com/spree/spree/issues/2094
      it "does not clear password on update" do
        expect(payment_method.preferred_password).to eq("haxme")
        put :update, id: payment_method.id, payment_method: { type: payment_method.class.to_s, preferred_password: "" }
        expect(response).to redirect_to(spree.edit_admin_payment_method_path(payment_method))

        payment_method.reload
        expect(payment_method.preferred_password).to eq("haxme")
      end
    end

    context "tries to save invalid payment" do
      it "doesn't break, responds nicely" do
        post :create, payment_method: { name: "", type: "Spree::Gateway::Bogus" }
      end
    end

    it "can create a payment method of a valid type" do
      expect {
        post :create, payment_method: { name: "Test Method", type: "Spree::Gateway::Bogus" }
      }.to change(Spree::PaymentMethod, :count).by(1)

      expect(response).to be_redirect
      expect(response).to redirect_to spree.edit_admin_payment_method_path(assigns(:payment_method))
    end

    it "can not create a payment method of an invalid type" do
      expect {
        post :create, payment_method: { name: "Invalid Payment Method", type: "Spree::InvalidType" }
      }.to change(Spree::PaymentMethod, :count).by(0)

      expect(response).to be_redirect
      expect(response).to redirect_to spree.new_admin_payment_method_path
    end

    describe "GET index" do
      subject { get :index }

      let!(:first_method) { GatewayWithPassword.create! name: "First", preferred_password: "1235" }
      let!(:second_method) { GatewayWithPassword.create! name: "Second", preferred_password: "1235" }

      before do
        second_method.move_to_top
      end

      it { is_expected.to be_success }
      it { is_expected.to render_template "index"  }

      it "respects the order of payment methods by position" do
        subject
        expect(assigns(:payment_methods).to_a).to eql([second_method, first_method])
      end
    end
  end
end
