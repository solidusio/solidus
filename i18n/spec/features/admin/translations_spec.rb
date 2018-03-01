require 'spec_helper'

RSpec.feature 'Translations', :js do
  stub_authorization!

  given!(:store) { create(:store) }

  background do
    reset_spree_preferences
  end

  context 'localization settings' do
    given(:language) { Spree.t(:this_file_language, scope: 'i18n', locale: 'de') }
    given(:french) { Spree.t(:this_file_language, scope: 'i18n', locale: 'fr') }

    background do
      visit spree.root_path
      store.update_attributes(preferred_available_locales: [])

      visit spree.edit_admin_general_settings_path
      click_on 'Locales'
    end

    scenario 'adds german to available locales' do
      within("#store-id-#{store.id}") do
        expect(page).to_not have_content(language)
        find('a[data-action="edit"]').click

        targetted_select2_search(language, from: '.available-locales')

        find('a[data-action="save"]').click

        wait_for_ajax

        expect(page).to have_content(language)
        expect(store.reload.preferred_available_locales).to include(:de)
      end
    end

    scenario 'adds french to available locales' do
      within("#store-id-#{store.id}") do
        expect(page).to_not have_content(french)
        find('a[data-action="edit"]').click

        targetted_select2_search(french, from: '.available-locales')

        find('a[data-action="save"]').click

        wait_for_ajax

        expect(page).to have_content(french)
        expect(store.reload.preferred_available_locales).to include(:fr)
      end
    end
  end
end
