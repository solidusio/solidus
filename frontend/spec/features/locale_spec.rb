# frozen_string_literal: true

require 'spec_helper'

describe 'setting locale', type: :feature do
  let!(:store) { create(:store) }
  def with_locale(locale)
    I18n.locale = locale
    stub_spree_preferences(Spree::Frontend::Config, locale: locale)
    yield
  ensure
    I18n.locale = I18n.default_locale
  end

  context 'shopping cart link and page' do
    include_context "fr locale"

    it 'should be in french' do
      with_locale('fr') do
        visit spree.root_path
        click_link 'Panier'
        expect(page).to have_content('Panier')
      end
    end
  end
end
