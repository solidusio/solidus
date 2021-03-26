# frozen_string_literal: true

require 'spec_helper'

describe 'switch currency', type: :feature, js: true do
  context 'with empty cart' do
    it 'user can switch currency' do
      create(:store, default_currency: 'USD', currencies: Set['EUR'])
      product = create(:product, price: 20)
      create(:price, variant: product.master, amount: 15, currency: 'EUR')

      visit spree.root_path

      expect(page).to have_content('$20')
      expect(page).not_to have_content('€15')

      select 'EUR', from: 'switch_to_currency'

      expect(page).to have_content('€15')
      expect(page).not_to have_content('$20')
    end
  end

  context 'with products added to the cart' do
    it 'user can empty cart and switch currency' do
      create(:store, default_currency: 'USD', currencies: Set['EUR'])
      product = create(:product, name: 'Product foo', price: 20)
      create(:price, variant: product.master, amount: 15, currency: 'EUR')

      visit spree.root_path

      expect(page).to have_content('$20')
      expect(page).not_to have_content('€15')

      click_on 'Product foo'
      click_on 'Add To Cart'
      accept_confirm do
        select 'EUR', from: 'switch_to_currency'
      end

      expect(page).not_to have_content('Checkout')

      visit spree.root_path

      expect(page).to have_content('€15')
      expect(page).not_to have_content('$20')
    end

    it 'user can keep cart and dismiss switching currency' do
      create(:store, default_currency: 'USD', currencies: Set['EUR'])
      product = create(:product, name: 'Product foo', price: 20)
      create(:price, variant: product.master, amount: 15, currency: 'EUR')

      visit spree.root_path

      expect(page).to have_content('$20')
      expect(page).not_to have_content('€15')

      click_on 'Product foo'
      click_on 'Add To Cart'
      dismiss_confirm do
        select 'EUR', from: 'switch_to_currency'
      end

      expect(page).to have_content('Checkout')

      visit spree.root_path

      expect(page).to have_content('$20')
      expect(page).not_to have_content('€15')
    end
  end
end
