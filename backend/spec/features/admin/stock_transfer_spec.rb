require 'spec_helper'

describe 'Stock Transfers', :type => :feature, :js => true do
  stub_authorization!

  let(:admin_user) { create(:admin_user) }
  let(:description) { 'Test stock transfer' }

  before do
    allow_any_instance_of(Spree::Admin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe 'create stock transfer' do
    it 'can create a stock transfer' do
      source_location = create(:stock_location_with_items, :name => 'NY')
      destination_location = create(:stock_location, :name => 'SF')

      visit spree.new_admin_stock_transfer_path
      select "SF", from: 'stock_transfer[source_location_id]'
      fill_in 'stock_transfer_description', with: description
      click_button 'Continue'

      expect(page.find('#stock_transfer_description').value).to eq description

      select "NY", from: 'stock_transfer[destination_location_id]'
      within "form.edit_stock_transfer" do
        page.find('button').trigger('click')
      end

      expect(page).to have_content('Stock Transfer has been successfully updated')
      expect(page).to have_css(:div, '#finalize-stock-transfer-warning')
      expect(page).to have_content("NY")
    end
  end

  describe 'view a stock transfer' do
    let(:stock_transfer) do
      create(:stock_transfer_with_items,
             source_location: source_location,
             destination_location: nil,
             description: "Test stock transfer")
    end
    let(:source_location) { create(:stock_location, name: 'SF') }

    context "stock transfer does not have a destination" do
      it 'displays the stock transfer details' do
        visit spree.admin_stock_transfer_path(stock_transfer)
        expect(page).to have_content("SF")
        expect(page).to have_content("Test stock transfer")
      end
    end
  end

  describe 'ship stock transfer' do
    let(:stock_transfer) { create(:stock_transfer_with_items) }

    before do
      stock_transfer.transfer_items do |item|
        item.update_attributes(expected_quantity: 1)
      end
    end

    describe "tracking info" do
      it 'adds tracking number' do
        visit spree.tracking_info_admin_stock_transfer_path(stock_transfer)

        fill_in 'stock_transfer_tracking_number', :with => "12345"
        click_button 'Save'

        expect(page).to have_content('Stock Transfer has been successfully updated')
        expect(stock_transfer.reload.tracking_number).to eq '12345'
      end
    end

    describe 'with enough stock' do
      it 'ships stock transfer' do
        visit spree.tracking_info_admin_stock_transfer_path(stock_transfer)
        click_link 'ship'

        find('#confirm-ship-link', visible: false).click
        expect(current_path).to eq spree.admin_stock_transfers_path
        expect(stock_transfer.reload.shipped_at).to_not be_nil
      end
    end

    describe 'without enough stock' do
      before do
        stock_transfer.transfer_items.each do |item|
          stock_transfer.source_location.stock_item(item.variant).set_count_on_hand(0)
        end
      end

      it 'does not ship stock transfer' do
        visit spree.tracking_info_admin_stock_transfer_path(stock_transfer)

        click_link 'ship'

        find('#confirm-ship-link', visible: false).click
        expect(current_path).to eq spree.tracking_info_admin_stock_transfer_path(stock_transfer)
        expect(stock_transfer.reload.shipped_at).to be_nil
      end
    end
  end
end
