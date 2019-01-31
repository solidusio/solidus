# frozen_string_literal: true

require 'spec_helper'

describe "Adjustments", type: :feature do
  stub_authorization!

  let!(:ship_address) { create(:address) }
  let!(:tax_zone) { create(:global_zone) } # will include the above address
  let!(:tax_rate) { create(:tax_rate, amount: 0.20, zone: tax_zone, tax_categories: [tax_category]) }

  let!(:order) do
    create(
      :completed_order_with_totals,
      line_items_attributes: [{ price: 10, variant: variant }] * 5,
      ship_address: ship_address,
    )
  end
  let!(:line_item) { order.line_items[0] }

  let(:tax_category) { create(:tax_category) }
  let(:variant) { create(:variant, tax_category: tax_category) }

  let!(:adjustment) { order.adjustments.create!(order: order, label: 'Rebate', amount: 10) }

  before(:each) do
    order.recalculate

    visit spree.admin_path
    click_link "Orders"
    within_row(1) { click_icon :edit }
    click_link "Adjustments"
  end

  context "admin managing adjustments" do
    it "should display the correct values for existing order adjustments" do
      within first('table tr', text: 'Tax') do
        expect(column_text(2)).to match(/TaxCategory - \d+ 20\.000%/)
        expect(column_text(3)).to eq("$2.00")
      end
    end

    it "only shows eligible adjustments" do
      expect(page).not_to have_content("ineligible")
    end
  end

  context "admin creating a new adjustment" do
    before(:each) do
      click_link "New Adjustment"
    end

    context "successfully" do
      it "should create a new adjustment" do
        fill_in "adjustment_amount", with: "10"
        fill_in "adjustment_label", with: "rebate"
        click_button "Continue"

        order.reload.all_adjustments.each do |adjustment|
          expect(adjustment.order_id).to equal(order.id)
        end
      end
    end

    context "with validation errors" do
      it "should not create a new adjustment" do
        fill_in "adjustment_amount", with: ""
        fill_in "adjustment_label", with: ""
        click_button "Continue"
        expect(page).to have_content("Label can't be blank")
        expect(page).to have_content("Amount is not a number")
      end
    end
  end

  context "admin editing an adjustment" do
    before(:each) do
      within('table tr', text: 'Rebate') do
        click_icon :edit
      end
    end

    context "successfully" do
      it "should update the adjustment" do
        fill_in "adjustment_amount", with: "99"
        fill_in "adjustment_label", with: "rebate 99"
        click_button "Continue"
        expect(page).to have_content("successfully updated!")
        expect(page).to have_content("rebate 99")
        within(".adjustments") do
          expect(page).to have_content("$99.00")
        end

        expect(page).to have_content("Total: $259.00")
      end
    end

    context "with validation errors" do
      it "should not update the adjustment" do
        fill_in "adjustment_amount", with: ""
        fill_in "adjustment_label", with: ""
        click_button "Continue"
        expect(page).to have_content("Label can't be blank")
        expect(page).to have_content("Amount is not a number")
      end
    end
  end

  context "deleting an adjustment" do
    context 'when the adjustment is finalized' do
      let!(:adjustment) { super().tap(&:finalize!) }

      it 'should not be possible' do
        within('table tr', text: 'Rebate') do
          expect(page).not_to have_css('.fa-trash')
        end
      end
    end

    it "should update the total", js: true do
      accept_alert do
        within('table tr', text: 'Rebate') do
          click_icon(:trash)
        end
      end

      expect(page).to have_content('Total: $170.00', normalize_ws: true)
    end
  end
end
