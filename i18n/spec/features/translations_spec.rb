# encoding: utf-8
RSpec.feature "Translations", :js do
  given(:language) { Spree.t(:this_file_language, scope: 'i18n', locale: 'pt-BR') }

  background do
    reset_spree_preferences
    SpreeI18n::Config.available_locales = [:en, :'pt-BR']
  end

  context 'page' do
    context 'switches locale from the dropdown' do
      scenario 'selected translation is applied' do
        visit spree.root_path
        select(language, from: Spree.t(:language, scope: 'i18n'))
        expect(page).to have_content('Início')
      end
    end
  end
end
