require 'spec_helper'

feature "Translations", js: true do
  stub_authorization!

  given(:language) { Spree.t(:'i18n.this_file_language', locale: 'pt-BR') }

  background do
    reset_spree_preferences
    SpreeI18n::Config.available_locales = [:en, :'pt-BR']
    SpreeI18n::Config.supported_locales = [:en, :'pt-BR']
  end

  context "products" do
    given(:product) { create(:product) }

    context "fills in translations fields" do
      scenario "displays translated name on frontend" do
        visit spree.admin_product_path(product)
        click_on "Translations"

        within("#attr_fields .name.en.odd") { fill_in_name "Pearl Jam" }
        within("#attr_fields .name.pt-BR.odd") { fill_in_name "Geleia de perola" }
        click_on "Update"

        change_locale
        expect(page).to have_content("Geleia de perola")
      end
    end

    context "option types" do
      given!(:option_type) { create(:option_value).option_type }

      scenario "displays translated name on frontend" do
        visit spree.admin_option_types_path
        find('.icon-flag').click

        within("#attr_fields .name.en.odd") { fill_in_name "shirt sizes" }
        within("#attr_list") { click_on "Presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "size" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "tamanho" }
        click_on "Update"

        change_locale
        visit spree.admin_option_types_path
        expect(page).to have_content("tamanho")
      end

      # Regression test for issue #354
      scenario "successfully creates an option type and go to its edit page" do
        visit spree.admin_option_types_path
        click_link "New Option Type"
        fill_in "Name", with: "Shirt Size"
        fill_in "Presentation", with: "Sizes"
        click_button "Create"

        expect(page).to have_content "Option Type \"Shirt Size\" has been successfully created"
        expect(page).to have_content "OPTION VALUES"
      end
    end

    context "option values" do
      given!(:option_type) { create(:option_value).option_type }

      scenario "displays translated name on frontend" do
        visit spree.edit_admin_option_type_path(option_type)
        find('.icon-flag').click

        within("#attr_fields .name.en.odd") { fill_in_name "big" }
        within("#attr_list") { click_on "Presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "big" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "grande" }
        click_on "Update"

        change_locale
        visit spree.edit_admin_option_type_path(option_type)
        expect(page).to have_selector("input[value=grande]")
      end
    end


    context "properties" do
      given!(:property) { create(:property) }

      scenario "displays translated name on frontend" do
        visit spree.admin_properties_path
        find('.icon-flag').click

        within("#attr_fields .name.pt-BR.odd") { fill_in_name "Modelo" }
        within("#attr_list") { click_on "Presentation" }
        within("#attr_fields .presentation.en.odd") { fill_in_name "Model" }
        within("#attr_fields .presentation.pt-BR.odd") { fill_in_name "Modelo" }
        click_on "Update"

        change_locale
        visit spree.admin_properties_path

        expect(page).to have_content("Modelo")
      end
    end
  end

  context "promotions" do
    given!(:promotion) { create(:promotion) }

    scenario "saves translated attributes properly" do
      visit spree.admin_promotions_path
      find('.icon-flag').click

      within("#attr_fields .name.en.odd") { fill_in_name "All free" }
      within("#attr_fields .name.pt-BR.odd") { fill_in_name "Salve salve" }
      click_on "Update"

      change_locale
      visit spree.admin_promotions_path
      expect(page).to have_content("Salve salve")
    end
  end

  context "taxonomies" do
    given!(:taxonomy) { create(:taxonomy) }

    scenario "display translated name on frontend" do
      visit spree.admin_taxonomies_path
      find('.icon-flag').click

      within("#attr_fields .name.en.odd") { fill_in_name "Guitars" }
      within("#attr_fields .name.pt-BR.odd") { fill_in_name "Guitarras" }
      click_on "Update"

      change_locale
      visit spree.root_path
      expect(page).to have_content('GUITARRAS')
    end
  end

  context "taxons", focus: true do
    given!(:taxon)    { create(:taxon) }
    given!(:taxonomy) { taxon.taxonomy }
    given!(:product) do
      product = create(:product)
      product.taxons << taxon
    end

    scenario "display translated name on frontend" do
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
      expect(page).to have_content('Acusticas')
    end
  end

  context "localization settings" do
    given(:language) { Spree.t(:'i18n.this_file_language', locale: 'de') }
    given(:french) { Spree.t(:'i18n.this_file_language', locale: 'fr') }

    background do
      SpreeI18n::Config.available_locales = [:en, :'pt-BR', :de]
      visit spree.edit_admin_general_settings_path
    end

    scenario "adds german to supported locales and pick it on front end" do
      targetted_select2_search(language, from: '#s2id_supported_locales_')
      click_on 'Update'
      change_locale
      expect(SpreeI18n::Config.supported_locales).to include(:de)
    end

    scenario "adds spanish to available locales" do
      targetted_select2_search(french, from: '#s2id_available_locales_')
      click_on 'Update'
      expect(SpreeI18n::Config.available_locales).to include(:fr)
    end
  end

  context "permalink routing" do
    given(:language) { Spree.t(:'i18n.this_file_language', locale: 'de') }
    given(:product) { create(:product) }

    scenario "finds the right product with permalink in a not active language" do
      SpreeI18n::Config.available_locales = [:en, :de]
      SpreeI18n::Config.supported_locales = [:en, :de]

      visit spree.admin_product_path(product)
      click_on "Translations"
      click_on "Slug"
      within("#attr_fields .slug.en.odd") { fill_in_name "en_link" }
      within("#attr_fields .slug.de.odd") { fill_in_name "de_link" }
      click_on "Update"

      visit spree.product_path 'en_link'
      expect(page).to have_content('Product')

      visit spree.product_path 'de_link'
      expect(page).to have_content('Product')
    end
  end

  private

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
