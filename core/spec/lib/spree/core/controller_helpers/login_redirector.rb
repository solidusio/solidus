require 'spec_helper'

class FakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Auth
end

describe Spree::Core::ControllerHelpers::LoginRedirector, type: :controller do
  let(:user) { instance_double(Spree.user_class, id: 1, last_incomplete_spree_order: nil) }

  describe '#redirect_unauthorized_access' do
    controller(FakesController) do
      def index
        redirect_unauthorized_access
      end
    end

    before { allow(controller).to receive_messages(try_spree_current_user: user) }

    context 'when logged in' do
      it 'redirects unauthorized path' do
        get :index
        expect(response).to redirect_to '/unauthorized'
      end
    end

    context 'when guest user' do
      let(:user) {}

      context 'with a login path' do
        before { allow(controller).to receive_messages(spree_login_path: '/login') }

        it 'redirects login path' do
          get :index
          expect(response).to redirect_to '/login'
        end
      end

      context 'without a login path' do
        it 'redirects root path' do
          get :index
          expect(response).to redirect_to '/unauthorized'
        end
      end
    end
  end
end
