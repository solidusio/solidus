require 'spec_helper'

describe "Shipments", type: :feature do
  include OrderFeatureHelper

  stub_authorization!

  let!(:order) { create(:order_ready_to_ship, number: "R100", state: "complete", line_items_count: 5) }

  # Regression test for https://github.com/spree/spree/issues/4025
  context "a shipment without a shipping method" do
    before do
      order.shipments.each do |s|
        # Deleting the shipping rates causes there to be no shipping methods
        s.shipping_rates.delete_all
      end
    end

    it "can still be displayed" do
      visit spree.edit_admin_order_path(order)
    end
  end

  context "shipping an order", js: true do
    before(:each) do
      visit spree.admin_path
      click_link "Orders"
      within_row(1) do
        click_link "R100"
      end
    end

    it "can ship a completed order" do
      find(".ship-shipment-button").click
      wait_for_ajax

      expect(page).to have_content("shipped package")
      expect(order.reload.shipment_state).to eq("shipped")
    end
  end

  context "moving variants between shipments", js: true do
    let!(:order) { create(:completed_order_with_pending_payment, number: "R100", state: "complete", line_items_count: 5) }
    let!(:la) { create(:stock_location, name: "LA") }
    before(:each) do
      visit spree.admin_path
      click_link "Orders"
      within_row(1) do
        click_link "R100"
      end
    end

    it "can move a variant to a new and to an existing shipment" do
      expect(order.shipments.count).to eq(1)
      shipment1 = order.shipments[0]

      within_row(1) { click_icon 'arrows-h' }
      complete_split_to('LA')

      expect(page).to have_css("#shipment_#{shipment1.id} tr.stock-item", count: 4)
      shipment2 = (order.reload.shipments.to_a - [shipment1]).first
      expect(page).to have_css("#shipment_#{shipment2.id} tr.stock-item", count: 1)

      within_row(2) { click_icon 'arrows-h' }
      complete_split_to("LA(#{shipment2.number})")
      expect(page).to have_css("#shipment_#{shipment2.id} tr.stock-item", count: 2)
      expect(page).to have_css("#shipment_#{shipment1.id} tr.stock-item", count: 3)
    end
  end
end
