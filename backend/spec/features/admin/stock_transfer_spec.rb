require 'spec_helper'

describe 'Stock Transfers', :type => :feature, :js => true do
  stub_authorization!

  it 'transfer between 2 locations' do
    source_location = create(:stock_location_with_items, :name => 'NY')
    destination_location = create(:stock_location, :name => 'SF')
    variant = Spree::Variant.last

    visit spree.new_admin_stock_transfer_path

    fill_in 'reference', :with => 'PO 666'

    select2_search variant.name, :from => 'Variant'

    click_button 'Add'
    click_button 'Transfer Stock'

    page.should have_content('NY')
    page.should have_content('SF')

    transfer = Spree::StockTransfer.last
    expect(transfer.stock_movements.size).to eq 2
  end

  describe 'received stock transfer' do
    def it_is_received_stock_transfer(page)
      page.should_not have_content("San Francisco")
      page.should have_content("New York")

      transfer = Spree::StockTransfer.last
      expect(transfer.stock_movements.size).to eq 1
      expect(transfer.source_location).to be_nil
    end

    it 'receive stock to a single location' do
      source_location = create(:stock_location_with_items, :name => 'New York')
      destination_location = create(:stock_location, :name => 'San Francisco')

      visit spree.new_admin_stock_transfer_path

      fill_in 'reference', :with => 'PO 666'
      check 'transfer_receive_stock'
      select('New York', :from => 'transfer_destination_location_id')

      variant = Spree::Variant.last
      select2_search variant.name, :from => 'Variant'

      click_button 'Add'
      click_button 'Transfer Stock'

      it_is_received_stock_transfer page
    end

    it 'forced to only receive there is only one location' do
      source_location = create(:stock_location_with_items, :name => 'New York')

      visit spree.new_admin_stock_transfer_path

      fill_in 'reference', :with => 'PO 666'

      select('New York', :from => 'transfer_destination_location_id')

      variant = Spree::Variant.last
      select2_search variant.name, :from => 'Variant'

      click_button 'Add'
      click_button 'Transfer Stock'

      it_is_received_stock_transfer page
    end
  end
end
