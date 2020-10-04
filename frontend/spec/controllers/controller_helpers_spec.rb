# frozen_string_literal: true

require 'spec_helper'

# In this file, we want to test that the controller helpers function correctly
# So we need to use one of the controllers inside Spree.
# ProductsController is good.
describe Spree::ProductsController, type: :controller do
  before do
    I18n.enforce_available_locales = false
    stub_spree_preferences(Spree::Frontend::Config, locale: :de)
    I18n.backend.store_translations(:de, spree: {
      i18n: { this_file_language: "Deutsch (DE)" }
    })
  end

  after do
    I18n.reload!
    I18n.locale = :en
    I18n.enforce_available_locales = true
  end

  # Regression test for https://github.com/spree/spree/issues/1184
  it "sets the default locale based off Spree::Frontend::Config[:locale]" do
    expect(I18n.locale).to eq(:en)
    get :index
    expect(I18n.locale).to eq(:de)
  end
end
