require 'spec_helper'

# In this file, we want to test that the controller helpers function correctly
# So we need to use one of the controllers inside Solidus.
# ProductsController is good.
describe Solidus::ProductsController, :type => :controller do

  before do
    I18n.enforce_available_locales = false
    Solidus::Frontend::Config[:locale] = :de
  end

  after do
    Solidus::Frontend::Config[:locale] = :en
    I18n.locale = :en
    I18n.enforce_available_locales = true
  end

  # Regression test for #1184
  it "sets the default locale based off Solidus::Frontend::Config[:locale]" do
    expect(I18n.locale).to eq(:en)
    spree_get :index
    expect(I18n.locale).to eq(:de)
  end
end
