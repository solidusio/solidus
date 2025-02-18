# frozen_string_literal: true

require "spec_helper"

describe "Properties", type: :feature do
  stub_authorization!

  before(:each) do
    visit spree.admin_path
    click_nav "Products"
  end

  context "Property index" do
    before do
      create(:property, name: "shirt size", presentation: "size")
      create(:property, name: "shirt fit", presentation: "fit")
      click_link "Property Types"
    end

    context "listing product properties" do
      it "should list the existing product properties" do
        within_row(1) do
          expect(column_text(1)).to eq("shirt size")
          expect(column_text(2)).to eq("size")
        end

        within_row(2) do
          expect(column_text(1)).to eq("shirt fit")
          expect(column_text(2)).to eq("fit")
        end
      end
    end

    context "searching properties" do
      it "should list properties matching search query", js: true do
        fill_in "q_name_cont", with: "size"
        click_button "Search"

        expect(page).to have_content("shirt size")
        expect(page).not_to have_content("shirt fit")
      end
    end
  end

  context "creating a property" do
    it "should allow an admin to create a new product property", js: true do
      click_link "Property Types"
      click_link "new_property_link"
      within("#new_property") { expect(page).to have_content("New Property Type") }

      fill_in "property_name", with: "color of band"
      fill_in "property_presentation", with: "color"
      click_button "Create"
      expect(page).to have_content("successfully created!")
    end
  end

  context "editing a property type" do
    before(:each) do
      create(:property)
      click_link "Property Types"
      within_row(1) { click_icon :edit }
    end

    it "should allow an admin to edit an existing product property" do
      fill_in "property_name", with: "model 99"
      click_button "Update"
      expect(page).to have_content("successfully updated!")
      expect(page).to have_content("model 99")
    end

    it "should show validation errors" do
      fill_in "property_name", with: ""
      click_button "Update"
      expect(page).to have_content("Name can't be blank")
    end
  end

  context "linking a property to a product", js: true do
    before do
      create(:product)
      visit spree.admin_products_path
      click_icon :edit
      click_link "Product Properties"
    end

    # Regression test for https://github.com/spree/spree/issues/2279
    it "successfully create and then remove product property" do
      fill_in_property

      check_persisted_property_row_count(1)

      delete_product_property

      check_persisted_property_row_count(0)
    end

    # Regression test for https://github.com/spree/spree/issues/4466
    it "successfully remove and create a product property at the same time" do
      fill_in_property

      expect(page).to have_css("tr.product_property", count: 1)

      click_button "Add Product Properties"
      within ".product_property:first-child" do
        find("[id$=_property_name]").set("New Property")
        find("[id$=_value]").set("New Value")
      end
      expect(page).to have_css("tr.product_property", count: 2)

      delete_product_property

      # Give fadeOut time to complete
      expect(page).to have_css("tr.product_property", count: 1)

      click_button "Update"

      expect(page).not_to have_content("Product is not found")

      check_persisted_property_row_count(0)
    end

    def fill_in_property
      expect(page).to have_content("Products")
      fill_in "product_product_properties_attributes_0_property_name", with: "A Property"
      fill_in "product_product_properties_attributes_0_value", with: "A Value"
      click_button "Update"
      click_link "Product Properties"
    end

    def delete_product_property
      accept_alert do
        within_row(1) { click_icon :trash }
      end
      expect(page).to have_content "successfully removed"
    end

    def check_persisted_property_row_count(expected_row_count)
      click_link "Product Properties"
      expect(page).to have_css("tbody#product_properties tr:not(#spree_new_product_property)", count: expected_row_count)
    end
  end
end
