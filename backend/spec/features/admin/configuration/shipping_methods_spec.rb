# frozen_string_literal: true

require 'spec_helper'

describe "Shipping Methods", type: :feature do
  stub_authorization!
  let!(:zone) { create(:global_zone) }
  let!(:shipping_method) { create(:shipping_method, zones: [zone]) }

  before do
    visit spree.admin_path
    click_link "Settings"
    click_link "Shipping"
  end

  context "show" do
    it "should display existing shipping methods" do
      within_row(1) do
        expect(column_text(1)).to eq(shipping_method.name)
        expect(column_text(2)).to eq(zone.name)
        expect(column_text(3)).to eq("Flat Rate")
        expect(column_text(4)).to eq("Yes")
      end
    end
  end

  context "create", js: true do
    it "creates a new shipping method and disables the submit button", :js do
      click_link "New Shipping Method"

      fill_in "shipping_method_name", with: "bullock cart"

      within("#shipping_method_categories_field") do
        check first("input[type='checkbox']")["name"]
      end

      click_on "Create"
      expect(current_path).to eql(spree.edit_admin_shipping_method_path(Spree::ShippingMethod.last))

      visit spree.new_admin_shipping_method_path
      page.execute_script "$('form').submit(function(e) { e.preventDefault()})"
      fill_in "shipping_method_name", with: "bullock cart"

      within("#shipping_method_categories_field") do
        check first("input[type='checkbox']")["name"]
      end

      click_on "Create"

      expect(page).to have_button("Create", disabled: true)
    end

    context 'with shipping method having a calculator with array or hash preference type' do
      before do
        class ComplexShipments < Spree::ShippingCalculator
          preference :amount, :decimal
          preference :currency, :string
          preference :mapping, :hash
          preference :list, :array

          def self.description
            "Complex Shipments"
          end
        end
        @calculators = Rails.application.config.spree.calculators.shipping_methods
        Rails.application.config.spree.calculators.shipping_methods = [ComplexShipments]
      end

      after do
        Rails.application.config.spree.calculators.shipping_methods = @calculators
      end

      it "does not show array and hash form fields" do
        click_link "New Shipping Method"

        fill_in "shipping_method_name", with: "bullock cart"

        within("#shipping_method_categories_field") do
          check first("input[type='checkbox']")["name"]
        end

        click_on "Create"
        select 'Complex Shipments', from: 'Base Calculator'
        click_on "Update"

        expect(page).to have_field('Amount')
        expect(page).to have_field('Currency')
        expect(page).to_not have_field('Mapping')
        expect(page).to_not have_field('List')
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/1331
  context "update" do
    it "can update the existing calculator", js: true do
      within("#listing_shipping_methods") do
        click_icon :edit
      end

      fill_in 'Amount', with: 20

      click_button "Update"

      expect(page).to have_content 'successfully updated'
      expect(page).to have_field 'Amount', with: '20.0'
    end

    it "can change the calculator", js: true do
      within("#listing_shipping_methods") do
        click_icon :edit
      end

      select 'Flexible Rate per Package Item', from: 'Base Calculator'

      fill_in 'First Item', with: 10
      fill_in 'Additional Item', with: 20

      click_button "Update"

      expect(page).to have_content 'successfully updated'
      expect(page).to have_field 'First Item', with: '10.0'
      expect(page).to have_field 'Additional Item', with: '20.0'
    end
  end
end
