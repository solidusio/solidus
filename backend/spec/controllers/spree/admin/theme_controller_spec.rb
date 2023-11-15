# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::ThemeController, type: :controller do
  stub_authorization!

  it 'sets the theme in a different session key for each system theme' do
    stub_spree_preferences(Spree::Backend::Config, themes: { foo: 'foo-path', bar: 'bar-path' })

    get :set, params: { switch_to_theme: 'foo', system_theme: 'light', format: :json }

    expect(session[:admin_light_theme]).to eq('foo')
    expect(session[:admin_dark_theme]).to eq(nil)
    expect(response).to have_http_status(:redirect)

    get :set, params: { switch_to_theme: 'bar', system_theme: 'dark', format: :json }
    expect(session[:admin_light_theme]).to eq('foo')
    expect(session[:admin_dark_theme]).to eq('bar')
    expect(response).to have_http_status(:redirect)
  end

  it 'responds with "not found" for a missing theme' do
    stub_spree_preferences(Spree::Backend::Config, themes: { foo: 'foo-path' })

    get :set, params: { switch_to_theme: 'bar', system_theme: 'dark', format: :json }

    expect(session[:admin_light_theme]).to eq(nil)
    expect(session[:admin_dark_theme]).to eq(nil)
    expect(response).to have_http_status(:redirect)
  end
end
