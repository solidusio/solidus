require 'spec_helper'

describe "Translations" do
  stub_authorization!

  let(:language) { I18n.t("this_file_language", locale: "pt-BR") }

  before(:each) do
    I18n.locale = I18n.default_locale
    reset_spree_preferences
    SpreeI18n::Config.available_locales = ['en', 'pt-BR']
    SpreeI18n::Config.supported_locales = ['en', 'pt-BR']
  end

  context "products", js: true do
    let(:product) { create(:product) }

    context "fills in translations fields" do
      it "displays translated name on frontend" do
        visit spree.admin_product_path(product)
        click_on "Translations"

        within("#attr_fields .name.en.odd") { fill_in_name "Pearl Jam" }
        within("#attr_fields .name.pt-BR.odd") { fill_in_name "Geleia de perola" }
        click_on "Update"

        change_locale
        page.should have_content("Geleia de perola")
      end
    end

    context "option types" do
      let!(:option_type) { create(:option_value).option_type }

      it "displays translated name on frontend" do
        visit spree.admin_option_types_path
        find('.icon-flag').click

        within("#attr_fields .name.en.odd") { fill_in_name "shirt sizes" }
        within("#attr_list") { click_on "presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "size" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "tamanho" }
        click_on "Update"

        visit spree.admin_product_path(product)
        select2_search "size", :from => "Option Types"
        click_button "Update"
        visit spree.admin_product_path(product)

        within('#sidebar') { click_link "Variants" }
        click_on "New Variant"
        click_button "Create"

        change_locale
        visit spree.product_path(product)
        page.should have_content("tamanho")
      end
    end
  end

  context "promotions", js: true do
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

  context "taxonomies", js: true do
    let!(:taxonomy) { create(:taxonomy) }

    it "display translated name on frontend" do
      visit spree.admin_taxonomies_path
      find('.icon-flag').click

      within("#attr_fields .name.en.odd") { fill_in_name "Guitars" }
      within("#attr_fields .name.pt-BR.odd") { fill_in_name "Guitarras" }
      click_on "Update"

      change_locale
      visit spree.root_path
      page.should have_content('GUITARRAS')
    end
  end

  context "taxons", js: true do
    let(:taxon) { create(:taxon) }
    let(:taxonomy) { taxon.taxonomy }

    it "display translated name on frontend" do
      visit spree.edit_admin_taxonomy_taxon_path(taxonomy.id, taxon.id)
      find('.icon-flag').click

      within("#attr_fields .name.en.odd") { fill_in_name "Acoustic" }
      within("#attr_fields .name.pt-BR.odd") { fill_in_name "Acusticas" }
      click_on "Update"

      change_locale
      visit spree.root_path
      page.should have_content('Acusticas')
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
