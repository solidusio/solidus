# frozen_string_literal: true

require 'spec_helper'

class FakesController < Spree::Api::BaseController
end

describe Spree::Api::BaseController, type: :controller do
  render_views
  controller(Spree::Api::BaseController) do
    rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

    def index
      render json: { "products" => [] }
    end
  end

  before do
    @routes = ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw { get 'index', to: 'spree/api/base#index' }
    end
  end

  context "when validating based on an order token" do
    let!(:order) { create :order }

    context "with a correct order token" do
      it "succeeds" do
        get :index, params: { order_token: order.guest_token, order_id: order.number }
        expect(response.status).to eq(200)
      end

      it "succeeds with an order_number parameter" do
        get :index, params: { order_token: order.guest_token, order_number: order.number }
        expect(response.status).to eq(200)
      end
    end

    context "with an incorrect order token" do
      it "returns unauthorized" do
        get :index, params: { order_token: "NOT_A_TOKEN", order_id: order.number }
        expect(response.status).to eq(401)
      end
    end
  end

  context "cannot make a request to the API" do
    it "without an API key" do
      get :index
      expect(json_response).to eq({ "error" => "You must specify an API key." })
      expect(response.status).to eq(401)
    end

    it "with an invalid API key" do
      request.headers["Authorization"] = "Bearer fake_key"
      get :index, params: {}
      expect(json_response).to eq({ "error" => "Invalid API key (fake_key) specified." })
      expect(response.status).to eq(401)
    end

    it "using an invalid token param" do
      get :index, params: { token: "fake_key" }
      expect(json_response).to eq({ "error" => "Invalid API key (fake_key) specified." })
    end
  end

  it "lets a subclass override the product associations that are eager-loaded" do
    expect(controller.respond_to?(:product_includes, true)).to be
  end

  context 'insufficient stock' do
    before do
      expect(subject).to receive(:authenticate_user).and_return(true)
      expect(subject).to receive(:index).and_raise(Spree::Order::InsufficientStock)
      get :index, params: { token: "fake_key" }
    end

    it "should return a 422" do
      expect(response.status).to eq(422)
    end

    it "returns an error message" do
      expect(json_response).to eq(
        { "errors" => ["Quantity is not available for items in your order"], "type" => "insufficient_stock" }
      )
    end
  end

  context 'lock_order' do
    let!(:order) { create :order }

    controller(Spree::Api::BaseController) do
      around_action :lock_order

      def index
        render json: { "products" => [] }
      end
    end

    context 'without an existing lock' do
      it 'succeeds' do
        get :index, params: { order_token: order.guest_token, order_id: order.number }
        expect(response.status).to eq(200)
      end
    end

    context 'with an existing lock' do
      around do |example|
        Spree::OrderMutex.with_lock!(order) { example.run }
      end

      it 'returns a 409 conflict' do
        get :index, params: { order_token: order.guest_token, order_id: order.number }
        expect(response.status).to eq(409)
      end
    end
  end
end
