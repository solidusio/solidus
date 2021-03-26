# frozen_string_literal: true

require 'spec_helper'

describe 'Stores', type: :feature do
  stub_authorization!

  context 'when adding a store' do
    before { visit spree.new_admin_store_path }

    it 'admin should be able to configure currencies' do
      expect(find('#store_default_currency').value).to eq ''

      fill_in 'store_name', with: 'Solidus Store'
      fill_in 'store_code', with: 'solidus'
      fill_in 'store_url', with: 'example.solidus.io'
      fill_in 'store_mail_from_address', with: 'from@solidus.io'
      select 'EUR', from: 'store_default_currency'
      select 'USD', from: 'store_currencies'
      select 'XOF', from: 'store_currencies'
      click_button 'Create'

      store = Spree::Store.last

      expect(store.default_currency).to eq 'EUR'
      expect(store.currencies).to eq Set['USD', 'XOF']
    end

    it 'admin should be able to create a store without currencies' do
      fill_in 'store_name', with: 'Solidus Store'
      fill_in 'store_code', with: 'solidus'
      fill_in 'store_url', with: 'example.solidus.io'
      fill_in 'store_mail_from_address', with: 'from@solidus.io'
      click_button 'Create'

      store = Spree::Store.last

      expect(store.reload.currencies).to eq Set[]
    end
  end

  context 'when editing a store' do
    let(:store) { create :store, default_currency: 'AUD', currencies: Set['USD', 'EUR'] }
    before { visit spree.edit_admin_store_path(store) }

    it 'admin should be able to change currencies' do
      select 'EUR', from: 'store_default_currency'
      unselect 'EUR', from: 'store_currencies'
      select 'XOF', from: 'store_currencies'
      click_button 'Update'
      expect(store.reload.default_currency).to eq 'EUR'
      expect(store.reload.currencies).to eq Set['USD', 'XOF']
    end

    it 'admin should be able to remove all currencies' do
      unselect 'EUR', from: 'store_currencies'
      unselect 'USD', from: 'store_currencies'
      click_button 'Update'
      expect(store.reload.currencies).to eq Set[]
    end
  end
end
