# frozen_string_literal: true

require 'spec_helper'

describe "Stock Items", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists stock items and allows navigating through scopes" do
    non_backorderable = create(:stock_item, backorderable: false)
    non_backorderable.variant.update!(sku: 'MY-SKU-1234567890')
    backorderable = create(:stock_item, backorderable: true)
    out_of_stock = begin
      item = create(:stock_item, backorderable: false)
      item.reduce_count_on_hand_to_zero
      item
    end
    low_stock = begin
      item = create(:stock_item, backorderable: false)
      item.set_count_on_hand(SolidusAdmin::Config[:low_stock_value] - 1)
      item
    end

    visit "/admin/stock_items"

    # `All` default scope
    expect(page).to have_content(non_backorderable.variant.sku)
    expect(page).to have_content(backorderable.variant.sku)
    expect(page).to have_content(out_of_stock.variant.sku)
    expect(page).to have_content(low_stock.variant.sku)

    # Edit stock item
    find('td', text: 'MY-SKU-1234567890').click
    fill_in :quantity_adjustment, with: 1
    click_on "Save"
    expect(find('tr', text: 'MY-SKU-1234567890')).to have_content('11')
    expect(find('tr', text: 'MY-SKU-1234567890')).to have_content('1 stock movement')

    click_on 'Back Orderable'
    expect(page).to have_css('[aria-current="true"]', text: 'Back Orderable')
    expect(page).to_not have_content(non_backorderable.variant.sku)
    expect(page).to have_content(backorderable.variant.sku)
    expect(page).to_not have_content(out_of_stock.variant.sku)
    expect(page).to_not have_content(low_stock.variant.sku)

    click_on 'Out Of Stock'
    expect(page).to have_css('[aria-current="true"]', text: 'Out Of Stock')
    expect(page).to_not have_content(non_backorderable.variant.sku)
    expect(page).to_not have_content(backorderable.variant.sku)
    expect(page).to have_content(out_of_stock.variant.sku)
    expect(page).to_not have_content(low_stock.variant.sku)

    click_on 'Low Stock'
    expect(page).to have_css('[aria-current="true"]', text: 'Low Stock')
    expect(page).to_not have_content(non_backorderable.variant.sku)
    expect(page).to_not have_content(backorderable.variant.sku)
    expect(page).to_not have_content(out_of_stock.variant.sku)
    expect(page).to have_content(low_stock.variant.sku)

    click_on 'In Stock'
    expect(page).to have_css('[aria-current="true"]', text: 'In Stock')
    expect(page).to have_content(non_backorderable.variant.sku)
    expect(page).to have_content(backorderable.variant.sku)
    expect(page).to_not have_content(out_of_stock.variant.sku)
    expect(page).to have_content(low_stock.variant.sku)

    expect(page).to be_axe_clean
  end
end
