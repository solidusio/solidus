# frozen_string_literal: true

require 'spec_helper'

describe 'api', type: :routing do
  let!(:current_disable_api_routes_setting) do
    Spree::Api::Config[:disable_api_routes]
  end

  context 'when disable_api_routes is enabled' do
    before do
      stub_spree_preferences(Spree::Api::Config, disable_api_routes: true)
      Rails.application.reload_routes!
    end

    it "does not mount the api routes" do
      aggregate_failures do
        expect(get: '/api/orders').to_not be_routable
        expect(get: '/api/products').to_not be_routable
      end
    end
  end

  context 'when disable_api_routes is disabled' do
    before do
      stub_spree_preferences(Spree::Api::Config, disable_api_routes: false)
      Rails.application.reload_routes!
    end

    it "mounts the api routes" do
      aggregate_failures do
        expect(get: '/api/orders').to be_routable
        expect(get: '/api/products').to be_routable
      end
    end
  end

  after do
    stub_spree_preferences(
      Spree::Api::Config,
      disable_api_routes: current_disable_api_routes_setting
    )

    Rails.application.reload_routes!
  end
end
