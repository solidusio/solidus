# encoding: utf-8
RSpec.feature "Translations", :js do
  given(:language) { Spree.t(:'i18n.this_file_language', locale: 'pt-BR') }

  background do
    reset_spree_preferences
    SpreeI18n::Config.available_locales = [:en, :'pt-BR']
    SpreeI18n::Config.supported_locales = [:en, :'pt-BR']
  end

  context 'page' do
    context 'switches locale from the dropdown' do
      scenario 'selected translation is applied' do
        visit '/'
        select('Português (BR)', from: 'Language')
        expect(page).to have_content('Início')
      end
    end
  end

  context 'product' do
    let!(:product) do
      create(:product, name: 'Antimatter',
             translations: [
               Spree::Product::Translation.new(locale: 'pt-BR',
                                               name: 'Antimatéria')
             ])
    end

    before do
      I18n.locale = 'pt-BR'
      Spree::Frontend::Config[:locale] = 'pt-BR'
    end

    after do
      I18n.locale = :en
      Spree::Frontend::Config[:locale] = :en
    end

    scenario 'displays translated product page' do
      visit '/products/antimatter'
      expect(page.title).to have_content('Antimatéria')
    end

    scenario 'displays translated products list' do
      visit '/products'
      expect(page).to have_content('Antimatéria')
    end
  end
end
