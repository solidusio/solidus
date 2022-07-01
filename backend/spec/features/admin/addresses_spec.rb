# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe 'Addresses', type: :feature do
  stub_authorization!
  let!(:country) { create(:country) }
  let!(:user_a) { create(:user_with_addresses, email: 'a@example.com') }
  let!(:user_b) { create(:user_with_addresses, email: 'b@example.com') }
  let!(:admin_role) { create(:role, name: 'admin') }
  let!(:user_role) { create(:role, name: 'user') }
  let!(:store) { create(:store) }

  before do
    visit spree.admin_path
    click_link 'Users'
  end

  context "editing addresses" do
    before { click_link user_a.email }

    it 'can edit user shipping address' do
      allow(Spree.user_class).to receive(:find_by).and_call_original
      allow(Spree.user_class).to receive(:find_by).with("1").and_return(user_a)

      click_link "Addresses"

      within("#admin_user_edit_addresses") do
        fill_in "user_ship_address_attributes_address1", with: "1313 Mockingbird Ln"
        click_button 'Update'
        expect(page).to have_field('user_ship_address_attributes_address1', with: "1313 Mockingbird Ln")
      end

      expect(user_a.reload.ship_address.address1).to eq "1313 Mockingbird Ln"
    end

    it 'can edit user billing address' do
      allow(Spree.user_class).to receive(:find_by).and_call_original
      allow(Spree.user_class).to receive(:find_by).with("1").and_return(user_a)

      click_link "Addresses"

      within("#admin_user_edit_addresses") do
        fill_in "user_bill_address_attributes_address1", with: "1313 Mockingbird Ln"
        click_button 'Update'
        expect(page).to have_field('user_bill_address_attributes_address1', with: "1313 Mockingbird Ln")
      end

      expect(user_a.reload.bill_address.address1).to eq "1313 Mockingbird Ln"
    end
  end
end
