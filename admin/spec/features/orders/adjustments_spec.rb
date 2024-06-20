# frozen_string_literal: true

require 'spec_helper'

describe "Order", :js, type: :feature do
  let(:order) { create(:order, number: "R123456789") }

  before do
    allow(SolidusAdmin::Config).to receive(:enable_alpha_features?) { true }
    sign_in create(:admin_user, email: 'admin@example.com')
  end

  it "allows locking and unlocking adjustments" do
    taxrate = create(:tax_rate)
    Spree::Adjustment.create(
      order: order,
      adjustable: order,
      amount: 10,
      label: "Test Adjustment",
      eligible: true,
      finalized: false,
      created_at: Time.current,
      updated_at: Time.current,
      included: false,
      source: taxrate,
      promotion_code_id: nil,
    )
    visit "/admin/orders/R123456789"

    click_on "Adjustments"
    expect(page).to have_content("Test Adjustment")

    expect(page).to be_axe_clean

    select_row("Test Adjustment")
    click_on "Lock"
    expect(page).to have_content("Locked successfully", wait: 5)

    select_row("Test Adjustment")
    click_on "Unlock"
    expect(page).to have_content("Unlocked successfully")

    select_row("Test Adjustment")
    click_on "Delete"
    expect(page).to have_content("Deleted successfully")
    expect(page).not_to have_content("Test Adjustment")
    expect(Spree::AdjustmentReason.count).to eq(0)

    expect(page).to be_axe_clean
  end

  it "can display an adjustment without a source" do
    Spree::Adjustment.create(
      order: order,
      adjustable: order,
      amount: 10,
      label: "No Source Adjustment",
      eligible: true,
      finalized: false,
      created_at: Time.current,
      updated_at: Time.current,
      included: false,
      source: nil,
      promotion_code_id: nil,
    )
    visit "/admin/orders/R123456789"

    click_on "Adjustments"
    expect(page).to have_content("No Source Adjustment")
    expect(page).to be_axe_clean
  end

  context "with a unit cancellation" do
    let(:order) { create(:order_ready_to_ship, number: "R123456789") }

    before do
      Spree::OrderCancellations.new(order).short_ship([order.inventory_units.first])
    end

    it "can display an adjustment with a unit cancellation" do
      visit "/admin/orders/R123456789"

      click_on "Adjustments"
      expect(page).to have_content("Cancellation - Short Ship")
      expect(page).to be_axe_clean
    end
  end

  context "with a shipment being adjusted" do
    let(:order) { create(:order_with_line_items, number: "R123456789") }

    before do
      order.shipments.first.adjustments.create!(
        order: order,
        label: "Manual shipping discount",
        amount: -2,
        source: nil
      )
    end

    it "can display a shipment adjustment" do
      visit "/admin/orders/R123456789"

      click_on "Adjustments"
      expect(page).to have_content("Manual shipping discount")
      expect(page).to be_axe_clean
    end
  end
end
