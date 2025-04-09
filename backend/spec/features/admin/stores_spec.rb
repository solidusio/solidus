# frozen_string_literal: true

require 'spec_helper'

describe 'Stores', type: :feature do
  stub_authorization!

  let!(:user_group) { create :user_group, group_name: 'Default Group' }
  let!(:new_user_group) { create :user_group, group_name: 'New Group' }

  context 'when adding a store' do
    before { visit spree.new_admin_store_path }

    it 'admin should be able to set the default_currency' do
      expect(find('#store_default_currency').value).to eq ''

      fill_in 'store_name', with: 'Solidus Store'
      fill_in 'store_code', with: 'solidus'
      fill_in 'store_url', with: 'example.solidus.io'
      fill_in 'store_mail_from_address', with: 'from@solidus.io'
      select 'EUR', from: 'store_default_currency'
      click_button 'Create'

      @store = Spree::Store.last

      expect(@store.default_currency).to eq 'EUR'
    end

    it 'admin should be able to set the default_cart_user_group' do
      expect(find('#store_default_cart_user_group_id').value).to eq ''

      fill_in 'store_name', with: 'Solidus Store'
      fill_in 'store_code', with: 'solidus'
      fill_in 'store_url', with: 'example.solidus.io'
      fill_in 'store_mail_from_address', with: 'from@solidus.io'
      select 'Default Group', from: 'store_default_cart_user_group_id'
      click_button 'Create'

      @store = Spree::Store.last

      expect(@store.default_cart_user_group).to eq user_group
    end
  end

  context 'when editing a store' do
    let(:store) { create :store, default_currency: 'AUD', default_cart_user_group: user_group }
    before { visit spree.edit_admin_store_path(store) }

    it 'admin should be able to change the default_currency' do
      select 'EUR', from: 'store_default_currency'
      click_button 'Update'
      expect(store.reload.default_currency).to eq 'EUR'
    end

    it 'admin should be able to change the default_cart_user_group' do
      select 'New Group', from: 'store_default_cart_user_group_id'
      click_button 'Update'

      expect(store.reload.default_cart_user_group).to eq new_user_group
    end
  end
end
