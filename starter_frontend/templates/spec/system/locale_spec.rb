# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'setting locale', type: :system do
  include_context 'fr locale'

  let!(:store) { create(:store) }

  context 'shopping cart link and page', :js do
    it 'should be in french' do
      visit root_path

      expect(page).to have_link('Cart')
      select('Français', from: 'Language:')
      expect(page).to have_content('Paramètres régionaux changés')
      click_link 'Panier'
      expect(page).to have_content('Votre panier est vide')
    end
  end
end
