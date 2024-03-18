# frozen_string_literal: true

require 'spec_helper'

describe "Stock Items", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  # We don't want multiple stock items per variant, and stock locations are created implicitly otherwise,
  # and their default is to create stock items for all variants, which in this spec we do manually.
  let!(:stock_location) { create(:stock_location, name: 'default', propagate_all_variants: false) }

  let(:backorderable_variant) { create(:variant, sku: 'backorderable', stock_items: []) }
  let(:non_backorderable_variant) { create(:variant, sku: 'non-backorderable', stock_items: []) }
  let(:out_of_stock_variant) { create(:variant, sku: 'out-of-stock', stock_items: []) }
  let(:low_stock_variant) { create(:variant, sku: 'low-stock', stock_items: []) }
  let!(:backorderable) { create(:stock_item, variant: backorderable_variant, backorderable: true) }
  let!(:non_backorderable) { create(:stock_item, variant: non_backorderable_variant, backorderable: false) }
  let!(:out_of_stock) { create(:stock_item, variant: out_of_stock_variant, backorderable: false, on_hand: 0) }
  let!(:low_stock) { create(:stock_item, variant: low_stock_variant, backorderable: false, on_hand: SolidusAdmin::Config.low_stock_value - 1) }

  it "lists stock items and allows navigating through scopes" do
    visit "/admin/stock_items"

    # `All` default scope
    expect(page).to have_content(non_backorderable.variant.sku)
    expect(page).to have_content(backorderable.variant.sku)
    expect(page).to have_content(out_of_stock.variant.sku)
    expect(page).to have_content(low_stock.variant.sku)

    # Edit stock item
    find('td', text: 'non-backorderable').click
    fill_in :quantity_adjustment, with: 1
    click_on "Save"
    expect(find('tr', text: 'non-backorderable')).to have_content('11')
    expect(find('tr', text: 'non-backorderable')).to have_content('1 stock movement')

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
