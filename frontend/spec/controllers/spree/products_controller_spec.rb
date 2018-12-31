# frozen_string_literal: true

require 'spec_helper'

describe Spree::ProductsController, type: :controller do
  let!(:product) { create(:product, available_on: 1.year.from_now) }

  # Regression test for https://github.com/spree/spree/issues/1390
  it "allows admins to view non-active products" do
    allow(controller).to receive_messages try_spree_current_user: mock_model(Spree.user_class, has_spree_role?: true, last_incomplete_spree_order: nil, spree_api_key: 'fake')
    get :show, params: { id: product.to_param }
    expect(response.status).to eq(200)
  end

  it "cannot view non-active products" do
    expect {
      get :show, params: { id: product.to_param }
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "should provide the current user to the searcher class" do
    user = mock_model(Spree.user_class, last_incomplete_spree_order: nil, spree_api_key: 'fake')
    allow(controller).to receive_messages try_spree_current_user: user
    expect_any_instance_of(Spree::Config.searcher_class).to receive(:current_user=).with(user)
    get :index
    expect(response.status).to eq(200)
  end

  # Regression test for https://github.com/spree/spree/issues/2249
  it "doesn't error when given an invalid referer" do
    current_user = mock_model(Spree.user_class, has_spree_role?: true, last_incomplete_spree_order: nil, generate_spree_api_key!: nil)
    allow(controller).to receive_messages try_spree_current_user: current_user
    request.env['HTTP_REFERER'] = "not|a$url"

    # Previously a URI::InvalidURIError exception was being thrown
    get :show, params: { id: product.to_param }
  end
end
