require 'spec_helper'

describe 'setting locale', type: :feature do
  let!(:store) { create(:store) }
  def with_locale(locale)
    I18n.locale = locale
    Spree::Frontend::Config[:locale] = locale
    yield
  ensure
    I18n.locale = I18n.default_locale
    Spree::Frontend::Config[:locale] = 'en'
  end

  context 'shopping cart link and page' do
    before do
      I18n.backend.store_translations(:fr,
       spree: {
         cart: 'Panier',
         shopping_cart: 'Panier'
      })
    end

    it 'should be in french' do
      with_locale('fr') do
        visit spree.root_path
        click_link 'Panier'
        expect(page).to have_content('Panier')
      end
    end
  end
end
