# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Core::ControllerHelpers::Auth, type: :controller do
  controller(ApplicationController) {
    include Spree::Core::ControllerHelpers::Auth
    def index; render plain: 'index'; end
  }

  describe '#current_ability' do
    it 'returns Spree::Ability instance' do
      expect(controller.current_ability.class).to eq Spree::Ability
    end
  end

  describe '#redirect_back_or_default' do
    before do
      def controller.index
        redirect_back_or_default('/')
      end
    end

    it 'redirects to session url' do
      session[:spree_user_return_to] = '/redirect'
      get :index
      expect(response).to redirect_to('/redirect')
    end
    it 'redirects to default page' do
      get :index
      expect(response).to redirect_to('/')
    end
  end

  describe '#set_guest_token' do
    before do
      def controller.index
        set_guest_token
        render plain: 'index'
      end
    end

    it 'sends cookie header' do
      get :index
      expect(response.headers["Set-Cookie"]).to match(/guest_token.*HttpOnly/)
      expect(response.cookies['guest_token']).not_to be_nil
    end

    context 'with guest_token_cookie_options configured' do
      it 'sends cookie with these options' do
        stub_spree_preferences(guest_token_cookie_options: {
          domain: :all,
          path: '/api'
        })
        get :index
        expect(response.headers["Set-Cookie"]).to match(/domain=(\.)?test\.host; path=\/api/)
      end

      it 'never overwrites httponly' do
        stub_spree_preferences(guest_token_cookie_options: {
          httponly: false
        })
        get :index
        expect(response.headers["Set-Cookie"]).to match(/guest_token.*HttpOnly/)
      end
    end
  end

  describe '#store_location' do
    it 'sets session return url' do
      allow(controller).to receive_messages(request: double(fullpath: '/redirect'))
      controller.store_location
      expect(session[:spree_user_return_to]).to eq '/redirect'
    end
  end

  describe '#unauthorized_redirect' do
    before do
      def controller.index
        authorize!(:show, :something)
      end
    end

    context "http_referrer is present" do
      before { request.env['HTTP_REFERER'] = "#{request.base_url}/redirect" }

      it "redirects back" do
        get :index
        expect(response).to redirect_to('/redirect')
      end
    end

    it "redirects to unauthorized" do
      get :index
      expect(response).to redirect_to('/unauthorized')
    end

    context "when unauthorized_redirect is set" do
      before do
        Spree.deprecator.silence do
          controller.unauthorized_redirect = -> { render plain: 'unauthorized', status: :unauthorized }
        end
      end

      after do
        Spree.deprecator.silence do
          controller.unauthorized_redirect = nil
        end
      end

      it "executes unauthorized_redirect" do
        get :index
        expect(response.body).to eq 'unauthorized'
        expect(response.status).to eq 401
      end
    end
  end

  describe "#spree_current_user" do
    context "when an ancestor defines it" do
      it "delegates" do
        controller = Class.new(ApplicationController) do
          include(Module.new do
            def spree_current_user
              :user
            end
          end)
          include Spree::Core::ControllerHelpers::Auth
        end.new

        expect(controller.spree_current_user).to eq :user
      end
    end

    context "when no ancestor defines it" do
      it "returns nil" do
        expect(controller.spree_current_user).to eq nil
      end
    end
  end
end
