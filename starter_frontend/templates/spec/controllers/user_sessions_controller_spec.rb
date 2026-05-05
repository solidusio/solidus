# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe UserSessionsController, type: :controller do
  let(:user) { create(:user) }

  before { @request.env['devise.mapping'] = Devise.mappings[:spree_user] }

  context "#create" do
    let(:format) { :html }
    let(:password) { 'secret' }

    subject do
      post(
        :create,
        params: {
          spree_user: {
            email: user.email,
            password: password
          },
          format: format
        }
      )
    end

    context "when using correct login information" do
      context 'with a guest token present' do
        before do
          request.cookie_jar.signed[:guest_token] = 'ABC'
        end

        it 'assigns orders with the correct token and no user present' do
          order = create(:order, email: user.email, guest_token: 'ABC', user_id: nil, created_by_id: nil)
          subject

          order.reload
          expect(order.user_id).to eq user.id
          expect(order.created_by_id).to eq user.id
        end

        it 'assigns orders with the correct token and no user or email present' do
          order = create(:order, guest_token: 'ABC', user_id: nil, created_by_id: nil)
          subject

          order.reload
          expect(order.user_id).to eq user.id
          expect(order.created_by_id).to eq user.id
        end

        it 'does not assign completed orders' do
          order = create(:order, email: user.email, guest_token: 'ABC',
                         user_id: nil, created_by_id: nil,
                         completed_at: 1.minute.ago)
          subject

          order.reload
          expect(order.user_id).to be_nil
          expect(order.created_by_id).to be_nil
        end

        it 'does not assign orders with an existing user' do
          order = create(:order, guest_token: 'ABC', user_id: 200)
          subject

          expect(order.reload.user_id).to eq 200
        end

        it 'does not assign orders with a different token' do
          order = create(:order, guest_token: 'DEF', user_id: nil, created_by_id: nil)
          subject

          expect(order.reload.user_id).to be_nil
        end
      end

      context "when html format is requested" do
        it "redirects to default after signing in" do
          subject
          expect(response).to redirect_to root_path
        end
      end

      context "when js format is requested" do
        let(:format) { :js }

        it "returns a json with ship and bill address" do
          subject
          parsed = ActiveSupport::JSON.decode(response.body)
          expect(parsed).to have_key("user")
          expect(parsed).to have_key("ship_address")
          expect(parsed).to have_key("bill_address")
        end
      end
    end

    context "when using incorrect login information" do
      let(:password) { 'wrong' }

      context "when html format is requested" do
        it "renders new template again with errors" do
          subject
          expect(response).to render_template(:new)
          expect(flash[:error]).to eq I18n.t(:'devise.failure.invalid')
        end
      end

      context "when js format is requested" do
        let(:format) { :js }
        it "returns json with the error" do
          subject
          parsed = ActiveSupport::JSON.decode(response.body)
          expect(parsed).to have_key("error")
        end
      end
    end
  end

  context "#destroy" do
    subject do
      delete(:destroy)
    end

    it "redirects to default after signing out" do
      subject
      expect(controller.spree_current_user).to be_nil
      expect(response).to redirect_to root_path
    end
  end
end
