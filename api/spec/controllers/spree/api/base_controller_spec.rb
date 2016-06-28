require 'spec_helper'

class FakesController < Spree::Api::BaseController
end

describe Spree::Api::BaseController, type: :controller do
  render_views
  controller(Spree::Api::BaseController) do
    rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

    def index
      render text: { "products" => [] }.to_json
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
        api_get :index, order_token: order.guest_token, order_id: order.number
        expect(response.status).to eq(200)
      end

      it "succeeds with an order_number parameter" do
        api_get :index, order_token: order.guest_token, order_number: order.number
        expect(response.status).to eq(200)
      end
    end

    context "with an incorrect order token" do
      it "returns unauthorized" do
        api_get :index, order_token: "NOT_A_TOKEN", order_id: order.number
        expect(response.status).to eq(401)
      end
    end
  end

  context "cannot make a request to the API" do
    it "without an API key" do
      api_get :index
      expect(json_response).to eq({ "error" => "You must specify an API key." })
      expect(response.status).to eq(401)
    end

    it "with an invalid API key" do
      request.headers["X-Spree-Token"] = "fake_key"
      get :index, {}
      expect(json_response).to eq({ "error" => "Invalid API key (fake_key) specified." })
      expect(response.status).to eq(401)
    end

    it "using an invalid token param" do
      get :index, token: "fake_key"
      expect(json_response).to eq({ "error" => "Invalid API key (fake_key) specified." })
    end
  end

  it 'chatches StandardError' do
    expect(subject).to receive(:authenticate_user).and_return(true)
    expect(subject).to receive(:load_user_roles).and_return(true)
    expect(subject).to receive(:index).and_raise("no joy")
    get :index, token: "fake_key"
    expect(json_response).to eq({ "exception" => "no joy" })
  end

  it 'raises Exception' do
    expect(subject).to receive(:authenticate_user).and_return(true)
    expect(subject).to receive(:load_user_roles).and_return(true)
    expect(subject).to receive(:index).and_raise(Exception.new("no joy"))
    expect {
      get :index, token: "fake_key"
    }.to raise_error(Exception, "no joy")
  end

  it "lets a subclass override the product associations that are eager-loaded" do
    expect(controller.respond_to?(:product_includes, true)).to be
  end

  describe '#error_during_processing' do
    controller(FakesController) do
      # GET /foo
      # Simulates a failed API call.
      def foo
        raise StandardError
      end
    end

    # What would be placed in config/initializers/spree.rb
    Spree::Api::BaseController.error_notifier = proc do |e, controller|
      MockHoneybadger.notify_or_ignore(e, rack_env: controller.request.env)
    end

    ##
    # Fake HB alert class
    class MockHoneybadger
      # https://github.com/honeybadger-io/honeybadger-ruby/blob/master/lib/honeybadger.rb#L136
      def self.notify_or_ignore(_exception, _opts = {})
      end
    end

    before do
      user = double(email: "spree@example.com")
      allow(user).to receive_message_chain :spree_roles, pluck: []
      allow(Spree.user_class).to receive_messages find_by: user
      @routes = ActionDispatch::Routing::RouteSet.new.tap do |r|
        r.draw { get 'foo' => 'fakes#foo' }
      end
    end

    it 'should notify notify_error_during_processing' do
      expect(MockHoneybadger).to receive(:notify_or_ignore).once.with(kind_of(Exception), rack_env: kind_of(Hash))
      api_get :foo, token: 123
      expect(response.status).to eq(422)
    end
  end

  context 'insufficient stock' do
    before do
      expect(subject).to receive(:authenticate_user).and_return(true)
      expect(subject).to receive(:index).and_raise(Spree::Order::InsufficientStock)
      get :index, token: "fake_key"
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
        render text: { "products" => [] }.to_json
      end
    end

    context 'without an existing lock' do
      it 'succeeds' do
        api_get :index, order_token: order.guest_token, order_id: order.number
        expect(response.status).to eq(200)
      end
    end

    context 'with an existing lock' do
      around do |example|
        Spree::OrderMutex.with_lock!(order) { example.run }
      end

      it 'returns a 409 conflict' do
        api_get :index, order_token: order.guest_token, order_id: order.number
        expect(response.status).to eq(409)
      end
    end
  end
end
