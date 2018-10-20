# frozen_string_literal: true

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

    def ship_shipment
      find(".ship-shipment-button").click

      expect(page).to have_content("Shipped package")
      expect(order.reload.shipment_state).to eq("shipped")
    end

    it "can ship a completed order" do
      expect {
        perform_enqueued_jobs {
          ship_shipment
        }
      }.to change{ ActionMailer::Base.deliveries.count }.by(1)
    end

    it "doesn't send a shipping confirmation email when ask to suppress the mailer" do
      uncheck 'Send Mailer'

      expect {
        perform_enqueued_jobs {
          ship_shipment
        }
      }.not_to change{ ActionMailer::Base.deliveries.count }
    end
  end

  context "destroying a shipment", js: true do
    before do
      visit spree.admin_path
      click_link "Orders"
      within_row(1) do
        click_link "R100"
      end
    end

    context "when the line item cannot be found" do
      it "shows the proper error message" do
        expect(page).to have_selector '.delete-item'
        order.shipments.first.line_items.each(&:destroy)
        accept_alert { first('.delete-item').click }
        expect(page).to have_content 'The resource you were looking for could not be found.'
      end
    end

    context "when the shipment has already been shipped" do
      it "shows the proper error message" do
        expect(page).to have_selector '.delete-item'
        order.shipments.first.ship!
        accept_alert { first('.delete-item').click }
        expect(page).to have_content 'Cannot remove items from a shipped shipment'
      end
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

      within('tr', text: order.line_items[0].sku) { click_icon 'arrows-h' }
      complete_split_to('LA')

      expect(page).to have_css("#shipment_#{shipment1.id} tr.stock-item", count: 4)
      shipment2 = (order.reload.shipments.to_a - [shipment1]).first
      expect(page).to have_css("#shipment_#{shipment2.id} tr.stock-item", count: 1)
      within "#shipment_#{shipment2.id}" do
        expect(page).to have_content("UPS Ground")
      end

      within('tr', text: order.line_items[1].sku) { click_icon 'arrows-h' }
      complete_split_to("LA(#{shipment2.number})")
      expect(page).to have_css("#shipment_#{shipment2.id} tr.stock-item", count: 2)
      expect(page).to have_css("#shipment_#{shipment1.id} tr.stock-item", count: 3)

      within "#shipment_#{shipment2.id}" do
        expect(page).to have_content("UPS Ground")
      end
    end

    context "with a ready-to-ship order" do
      let(:variant) { create(:variant) }
      let!(:order) do
        create(
          :order_ready_to_ship,
          number: "R100",
          line_items_attributes: [{ variant: variant, quantity: 5 }]
        )
      end

      it "can transfer all items to a new location" do
        expect(order.shipments.count).to eq(1)

        within('tr', text: order.line_items[0].sku) { click_icon 'arrows-h' }
        complete_split_to('LA', quantity: 5)

        expect(page).to_not have_content("package from 'NY Warehouse'")
        expect(page).to have_content("package from 'LA'")
      end
    end
  end
end
