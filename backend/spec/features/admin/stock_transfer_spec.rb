require 'spec_helper'

describe 'Stock Transfers', :type => :feature, :js => true do
  stub_authorization!

  let(:admin_user) { create(:admin_user) }
  let(:description) { 'Test stock transfer' }

  before do
    Spree::Admin::BaseController.any_instance.stub(:spree_current_user).and_return(admin_user)
  end

  it 'can create a stock transfer' do
    source_location = create(:stock_location_with_items, :name => 'NY')
    destination_location = create(:stock_location, :name => 'SF')

    visit spree.new_admin_stock_transfer_path
    select "SF", from: 'stock_transfer[source_location_id]'
    fill_in 'stock_transfer_description', with: description
    click_button 'Continue'

    expect(page).to have_content(admin_user.email)
    expect(page.find('#stock_transfer_description').value).to eq description

    select "NY", from: 'stock_transfer[destination_location_id]'
    within "form.edit_stock_transfer" do
      page.find('button').trigger('click')
    end

    expect(page).to have_css('#listing_stock_transfers') # wait for page to load
    expect(current_path).to eq spree.admin_stock_transfers_path

    within "#listing_stock_transfers" do
      expect(page).to have_content("NY")
      expect(page).to have_content("SF")
      expect(page).to have_content(Spree::StockTransfer.order(:id).last.number)
    end
  end
end
