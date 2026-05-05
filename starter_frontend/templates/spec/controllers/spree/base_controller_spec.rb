# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::BaseController, type: :controller do
  describe '#unauthorized_redirect' do
    controller(described_class) do
      def index; authorize!(:read, :something); end
    end

    before do
      allow(Spree::Auth::Engine).to receive(:redirect_back_on_unauthorized?).and_return(true)
    end

    context "when user is logged in" do
      before { sign_in(create(:user)) }

      context "when http_referrer is not present" do
        it "redirects to unauthorized path" do
          get :index
          expect(response).to redirect_to(unauthorized_path)
        end
      end

      context "when http_referrer is present" do
        let(:request_referer_path) { '/redirect' }
        let(:request_referer) { "#{request.protocol}#{request.host}#{request_referer_path}" }

        before { request.env['HTTP_REFERER'] = request_referer }

        it "redirects back" do
          get :index
          expect(response).to redirect_to(request_referer_path)
        end
      end
    end

    context "when user is not logged in" do
      context "when http_referrer is not present" do
        it "redirects to login path" do
          get :index
          expect(response).to redirect_to(login_path)
        end
      end

      context "when http_referrer is present" do
        let(:request_referer_path) { '/redirect' }
        let(:request_referer) { "#{request.protocol}#{request.host}#{request_referer_path}" }

        before { request.env['HTTP_REFERER'] = request_referer }

        it "redirects back" do
          get :index
          expect(response).to redirect_to(request_referer_path)
        end
      end
    end
  end
end
