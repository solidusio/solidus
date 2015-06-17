# encoding: utf-8
RSpec.feature "Translations", :js do
  given(:language) { Spree.t(:this_file_language, scope: 'i18n', locale: 'pt-BR') }

  background do
    reset_spree_preferences
    SpreeI18n::Config.available_locales = [:en, :'pt-BR']
  end

  context 'page' do
    context 'switches locale from the dropdown' do
      before do
        visit spree.root_path
        select(language, from: Spree.t(:language, scope: 'i18n'))
      end

      scenario 'selected translation is applied' do
        expect(page).to have_content(Spree.t(:home, locale: 'pt-BR'))
      end

      scenario 'JS cart link is translated' do
        expect(page).to have_content(Spree.t(:cart, locale: 'pt-BR'))
      end
    end
  end
end
