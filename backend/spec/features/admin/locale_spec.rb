require 'spec_helper'

describe "setting locale", :type => :feature do
  stub_authorization!

  before do
    I18n.locale = I18n.default_locale
    I18n.backend.store_translations(:fr,
      :date => {
        :month_names => [],
      },
      :solidus => {
        :admin => {
          :tab => { :orders => "Ordres" }
        },
        :listing_orders => "Ordres",
      })
    Solidus::Backend::Config[:locale] = "fr"
  end

  after do
    I18n.locale = I18n.default_locale
    Solidus::Backend::Config[:locale] = "en"
  end

  it "should be in french" do
    visit solidus.admin_path
    expect(page).to have_content("Ordres")
  end
end
