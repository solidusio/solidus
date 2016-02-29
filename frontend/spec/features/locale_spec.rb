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

  shared_examples "localized error message" do
    include_context 'checkout setup'

    it 'shows translated jquery.validate error messages', js: true do
      visit spree.root_path
      click_link mug.name
      click_button 'add-to-cart-button'
      with_locale(locale) do
        visit '/checkout/address'
        find('.form-buttons input[type=submit]').click

        %w(firstname lastname address1 city).each do |attr|
          expect(find(".field#b#{attr} label.error")).to have_text(message)
        end
      end
    end
  end

  context 'checkout form validation messages' do
    context 'en' do
      let(:locale) { 'en' }
      let(:message) { 'This field is required.' }
      it_behaves_like "localized error message"
    end

    context 'fr' do
      let(:locale) { 'fr' }
      let(:message) { 'Ce champ est obligatoire.' }
      it_behaves_like "localized error message"
    end

    context 'de' do
      let(:locale) { 'de' }
      let(:message) { 'Dieses Feld ist ein Pflichtfeld.' }
      it_behaves_like "localized error message"
    end
  end
end
