# frozen_string_literal: true

require 'spec_helper'

describe "Cancel items" do
  stub_authorization!

  let!(:order) do
    create(
      :order_ready_to_ship,
      number: "R100",
      state: "complete",
      line_items_count: 1
    )
  end

  def visit_order
    visit spree.admin_path
    click_link "Orders"
    within_row(1) do
      click_link "R100"
    end
  end

  context "when some items are cancelable" do
    it "can cancel the item" do
      visit_order

      click_link 'Cancel Items'

      within_row(1) do
        check 'inventory_unit_ids[]'
      end

      click_button "Cancel Items"
      expect(page).to have_content("Inventory canceled")
      expect(page).to have_content("1 x Canceled")
    end
  end

  context "when all items are not cancelable" do
    before { order.inventory_units.each(&:cancel!) }

    it "does not display the link to cancel items" do
      visit_order

      expect(page).to have_no_content('Cancel Items')
    end
  end
end
