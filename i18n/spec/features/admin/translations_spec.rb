require 'spec_helper'

describe "Product Translations tab" do
  stub_authorization!

  let(:language) { I18n.t("this_file_language", locale: "pt-BR") }

  before(:each) do
    reset_spree_preferences
    Spree::Config.all_locales = ['en', 'pt-BR']
    Spree::Config.supported_locales = ['en', 'pt-BR']
  end

  context "fills in product translations", js: true do
    let(:product) { create(:product) }

    it "displays translated name on frontend" do
      visit spree.admin_product_path(product)
      click_on "Translations"

      within("#attr_fields .name.en.odd") { fill_in_name "Pearl Jam" }
      within("#attr_fields .name.pt-BR.odd") { fill_in_name "Academia da Berlinda" }
      click_on "Update"

      change_locale
      page.should have_content("Academia da Berlinda")
    end
  end

  context "fills in promotion translations", js: true do
    let!(:promotion) { create(:promotion) }

    it "saves translated attributes properly" do
      visit spree.admin_promotions_path
      find('.icon-flag').click

      within("#attr_fields .name.en.odd") { fill_in_name "All free" }
      within("#attr_fields .name.pt-BR.odd") { fill_in_name "Salve salve" }
      click_on "Update"

      change_locale
      visit spree.admin_promotions_path
      page.should have_content("Salve salve")
    end
  end

  # sleep 1 second to make sure the ajax request process properly
  def change_locale
    visit spree.root_path
    within("#locale-select") { select language, from: "locale" }
    sleep 1
    visit spree.root_path
  end

  def fill_in_name(value)
    fill_in first("input[type='text']")["name"], with: value
  end
end
