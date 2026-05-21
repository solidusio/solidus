# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'current order tracking', type: :request, with_signed_in_user: true do
  let!(:store) { create(:store) }
  let(:user) { create(:user) }

  class TestController < StoreController
    def create_order
      @order = current_order(create_order_if_necessary: true)
      head :ok
    end

    def not_create_order
      head :ok
    end
  end

  before do
    Rails.application.routes.draw do
      get '/test', to: 'test#create_order'
      get '/test2', to: 'test#not_create_order'
    end
  end
  after do
    Rails.application.reload_routes!
  end

  it 'automatically tracks who the order was created by & IP address' do
    get '/test'

    expect(assigns[:order].created_by).to eq user
    expect(assigns[:order].last_ip_address).to eq "127.0.0.1"
  end

  context "current order creation" do
    it "doesn't create a new order out of the blue" do
      expect do
        get '/test2'
      end.not_to(change { Spree::Order.count })
    end
  end
end
