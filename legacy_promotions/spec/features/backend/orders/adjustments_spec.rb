# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adjustments", type: :feature do
  stub_authorization!

  context "when the order is completed" do
    let!(:ship_address) { create(:address) }
    let!(:tax_zone) { create(:global_zone) } # will include the above address
    let!(:tax_rate) { create(:tax_rate, amount: 0.20, zone: tax_zone, tax_categories: [tax_category]) }

    let!(:order) do
      create(
        :completed_order_with_totals,
        line_items_attributes: [{ price: 10, variant: variant }] * 5,
        ship_address: ship_address
      )
    end
    let!(:line_item) { order.line_items[0] }

    let(:tax_category) { create(:tax_category) }
    let(:variant) { create(:variant, tax_category: tax_category) }

    let!(:non_eligible_adjustment) { order.adjustments.create!(order: order, label: "Non-Eligible", amount: 10, eligible: false) }
    let!(:adjustment) { order.adjustments.create!(order: order, label: "Rebate", amount: 10) }

    before(:each) do
      order.recalculate

      visit spree.admin_path
      click_link "Orders"
      within_row(1) { click_icon :edit }
      click_link "Adjustments"
    end

    context "admin managing adjustments" do
      it "shows both eligible and non-eligible adjustments" do
        expect(page).to have_content("Rebate")
        expect(page).to have_content("Non-Eligible")
        expect(find("tr", text: "Rebate")[:class]).not_to eq("adjustment-ineligible")
        expect(find("tr", text: "Non-Eligible")[:class]).to eq("adjustment-ineligible")
      end
    end
  end
end
