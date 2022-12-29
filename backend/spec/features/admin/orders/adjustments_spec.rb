# frozen_string_literal: true

require 'spec_helper'

describe "Adjustments", type: :feature do
  stub_authorization!

  context "when the order is completed" do
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

    let!(:non_eligible_adjustment) { order.adjustments.create!(order: order, label: 'Non-Eligible', amount: 10, eligible: false) }
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

      it "shows both eligible and non-eligible adjustments" do
        expect(page).to have_content("Rebate")
        expect(page).to have_content("Non-Eligible")
        expect(find('tr', text: 'Rebate')[:class]).not_to eq('adjustment-ineligible')
        expect(find('tr', text: 'Non-Eligible')[:class]).to eq('adjustment-ineligible')
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

    context "admin bulk editing adjustments" do
      it "allows finalizing all the adjustments" do
        order.all_adjustments.each(&:unfinalize!)

        click_button "Finalize All Adjustments"

        expect(order.reload.adjustments.all?(&:finalized?)).to be(true)
      end

      it "allows unfinalizing all the adjustments" do
        order.all_adjustments.each(&:finalize!)

        click_button "Unfinalize All Adjustments"

        expect(order.reload.adjustments.any?(&:finalized?)).to be(false)
      end

      it "can't finalize via a GET request" do
        order.all_adjustments.each(&:unfinalize!)

        expect {
          visit "/admin/orders/#{order.number}/adjustments/finalize"
        }.to raise_error(ActionController::RoutingError)

        expect(order.reload.adjustments.any?(&:finalized?)).to be(false)
      end

      it "can't unfinalize via a GET request" do
        order.all_adjustments.each(&:finalize!)

        expect {
          visit "/admin/orders/#{order.number}/adjustments/unfinalize"
        }.to raise_error(ActionController::RoutingError)

        expect(order.reload.adjustments.all?(&:finalized?)).to be(true)
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

  context "when the order is not completed" do
    let(:order) { create(:order_ready_to_complete) }

    before do
      visit spree.edit_admin_order_path(order)
      click_link "Adjustments"
    end

    context "when the order is not complete" do
      context "when the user can edit and update orders" do
        custom_authorization! do |_user|
          can :update, Spree::Order
          can :edit, Spree::Order
        end

        it "allows to enter a coupon code", :js do
          expect(page).to have_content('Add Coupon Code')
          expect(page).to have_selector('input#coupon_code')
        end
      end

      context "when the user can edit but cannot update orders" do
        custom_authorization! do |_user|
          cannot :update, Spree::Order
          can :edit, Spree::Order
        end

        it "doesn't allow to enter a coupon code" do
          expect(page).not_to have_content('Add Coupon Code')
          expect(page).not_to have_selector('input#coupon_code')
        end
      end
    end
  end
end
