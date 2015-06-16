RSpec.feature "Translations", :js do
  stub_authorization!

  given!(:store) { create(:store) }

  background do
    reset_spree_preferences
  end

  context "localization settings" do
    given(:language) { Spree.t(:this_file_language, scope: 'i18n', locale: 'de') }
    given(:french) { Spree.t(:this_file_language, scope: 'i18n', locale: 'fr') }

    background do
      SpreeI18n::Config.available_locales = []
      visit spree.edit_admin_general_settings_path
    end

    scenario "adds german to available locales" do
      targetted_select2_search(language, from: '#s2id_available_locales_')
      click_on 'Update'
      expect(SpreeI18n::Config.available_locales).to include(:de)
    end

    scenario "adds french to available locales" do
      targetted_select2_search(french, from: '#s2id_available_locales_')
      click_on 'Update'
      expect(SpreeI18n::Config.available_locales).to include(:fr)
    end
  end
end
