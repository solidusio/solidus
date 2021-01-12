# frozen_string_literal: true

require 'spec_helper'

describe 'Stock Items Management', js: true do
  stub_authorization!

  let(:admin_user)   { create(:admin_user) }
  let!(:variant_1) { create(:variant) }
  let!(:variant_2) { create(:variant) }
  let!(:stock_location) { create(:stock_location_without_variant_propagation) }

  scenario 'User can add a new stock locations to any variant' do
    visit spree.admin_stock_items_path
    within('.js-add-stock-item', match: :first) do
      find('[name="stock_location_id"]').select(stock_location.name)
      fill_in('count_on_hand', with: 10)
      click_on('Create')
    end
    expect(page).to have_content("Created successfully")
  end
end
