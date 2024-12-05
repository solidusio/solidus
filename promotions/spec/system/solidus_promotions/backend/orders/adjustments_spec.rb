# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adjustments", :pending, type: :feature do
  stub_authorization!

  let!(:ship_address) { create(:address) }
  let!(:tax_zone) { create(:global_zone) } # will include the above address
  let!(:tax_rate) { create(:tax_rate, name: "Sales Tax", amount: 0.20, zone: tax_zone, tax_categories: [tax_category]) }

  let!(:line_item) { order.line_items[0] }

  let(:tax_category) { create(:tax_category) }
  let(:variant) { create(:variant, tax_category:) }

  before(:each) do
    order.recalculate

    visit spree.admin_path
    click_link "Orders"
    uncheck "Only show complete orders"
    click_button "Filter Results"
    within_row(1) { click_icon :edit }
    click_link "Adjustments"
  end

  let!(:order) { create(:order, line_items_attributes: [{ price: 10, variant: }]) }

  context "when the order is completed" do
    let!(:order) do
      create(
        :completed_order_with_totals,
        line_items_attributes: [{ price: 10, variant: }],
        ship_address:
      )
    end

    let!(:adjustment) { order.adjustments.create!(order:, label: "Rebate", amount: 10) }

    it "shows adjustments" do
      expect(page).to have_content("Adjustments")
    end

    context "when the promotion system is configured to allow applying promotions to completed orders" do
      before do
        expect(SolidusPromotions.config).to receive(:recalculate_complete_orders).and_return(true)
      end

      it "shows input field for promotion code" do
        expect(page).to have_content("Adjustments")
        expect(page).to have_field("coupon_code")
      end
    end

    context "when the promotion system is configured to not allow applying promotions to completed orders" do
      before do
        expect(SolidusPromotions.config).to receive(:recalculate_complete_orders).and_return(false)
      end

      it "does not show input field for promotion code" do
        expect(page).to have_content("Adjustments")
        expect(page).not_to have_field("coupon_code")
      end
    end
  end

  it "shows the input field for applying a promotion" do
    expect(page).to have_field("coupon_code")
  end

  context "creating a manual adjustment" do
    let!(:adjustment_reason) { create(:adjustment_reason, name: "Friendly customer") }
    before do
      click_link "New Adjustment"
    end

    it "creates a new adjustment" do
      fill_in "adjustment_amount", with: "5"
      fill_in "adjustment_label", with: "Test Adjustment"
      select "Friendly customer", from: "Reason"
      click_button "Continue"
      expect(page).to have_content("Adjustment has been successfully created!")
      expect(page).to have_content("Test Adjustment")
    end
  end
end
