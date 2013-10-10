require 'spec_helper'

describe "Translations" do
  stub_authorization!

  let(:language) { Spree.t(:'i18n.this_file_language', locale: 'pt-BR') }

  before(:each) do
    reset_spree_preferences
    SpreeI18n::Config.available_locales = [:en, :'pt-BR']
    SpreeI18n::Config.supported_locales = [:en, :'pt-BR']
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
        within("#attr_list") { click_on "Presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "size" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "tamanho" }
        click_on "Update"

        change_locale
        visit spree.admin_option_types_path
        page.should have_content("tamanho")
      end
    end

    context "option values" do
      let!(:option_type) { create(:option_value).option_type }

      it "displays translated name on frontend" do
        visit spree.edit_admin_option_type_path(option_type)
        find('.icon-flag').click

        within("#attr_fields .name.en.odd") { fill_in_name "big" }
        within("#attr_list") { click_on "Presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "big" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "grande" }
        click_on "Update"

        change_locale
        visit spree.edit_admin_option_type_path(option_type)
        page.should have_selector("input[value=grande]")
      end
    end


    context "properties" do
      let!(:property) { create(:property) }

      it "displays translated name on frontend" do
        visit spree.admin_properties_path
        find('.icon-flag').click

        within("#attr_fields .name.pt-BR.odd") { fill_in_name "Modelo" }
        within("#attr_list") { click_on "Presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "Model" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "Modelo" }
        click_on "Update"

        change_locale
        visit spree.admin_properties_path

        page.should have_content("Modelo")
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

      visit spree.edit_admin_taxonomy_taxon_path(taxonomy.id, taxon.id)
      find('.icon-flag').click

      # ensure we're not duplicating translated records on database
      expect {
        click_on "Update"
      }.not_to change { taxon.translations.count }

      change_locale
      visit spree.root_path
      page.should have_content('Acusticas')
    end
  end

  context "localization settings", js: true do
    let(:language) { Spree.t(:'i18n.this_file_language', locale: 'de') }
    let(:french) { Spree.t(:'i18n.this_file_language', locale: 'fr') }

    before do
      SpreeI18n::Config.available_locales = [:en, :'pt-BR', :de]
      visit spree.edit_admin_general_settings_path
    end

    it "adds german to supported locales and pick it on front end" do
      targetted_select2_search(language, from: '#s2id_supported_locales_')
      click_on 'Update'
      change_locale
      SpreeI18n::Config.supported_locales.should include(:de)
    end

    it "adds spanish to available locales" do
      targetted_select2_search(french, from: '#s2id_available_locales_')
      click_on 'Update'
      SpreeI18n::Config.available_locales.should include(:fr)
    end
  end

  context "permalink routing", js: true do
    let(:language) { Spree.t(:'i18n.this_file_language', locale: 'de') }
    let(:product) { create(:product) }

    it "finds the right product with permalink in a not active language" do
      SpreeI18n::Config.available_locales = [:en, :de]
      SpreeI18n::Config.supported_locales = [:en, :de]

      visit spree.admin_product_path(product)
      click_on "Translations"
      click_on "Permalink"
      within("#attr_fields .permalink.en.odd") { fill_in_name "en_link" }
      within("#attr_fields .permalink.de.odd") { fill_in_name "de_link" }
      click_on "Update"

      visit spree.product_path 'en_link'
      page.should have_content('Product')

      visit spree.product_path 'de_link'
      page.should have_content('Product')
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
