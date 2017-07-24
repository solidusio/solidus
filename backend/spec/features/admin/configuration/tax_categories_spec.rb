require 'spec_helper'

describe "Tax Categories", type: :feature do
  stub_authorization!

  context "admin creating new tax category" do
    before(:each) do
      visit spree.admin_path
      click_link "Taxes"
      click_link "Tax Categories"
      click_link "admin_new_tax_categories_link"
    end

    it "should be able to create new tax category" do
      expect(page).to have_content("New Tax Category")
      fill_in "tax_category_name", with: "sports goods"
      fill_in "tax_category_description", with: "sports goods desc"
      click_button "Create"
      expect(page).to have_content("successfully created!")
    end

    it "should show validation errors if there are any" do
      click_button "Create"
      expect(page).to have_content("Name can't be blank")
    end
  end

  context "Viewing the tax categories index", js: true do
    let!(:tax_category) do
      FactoryGirl.create(
        :tax_category,
        name: "Default",
        tax_code: "ABC123",
        description: "Description",
        is_default: true
      )
    end

    it "should be able to edit a tax category without leaving the page" do
      visit spree.admin_tax_categories_path

      within "#spree_tax_category_#{tax_category.id}" do
        expect(page).to have_field "tax_category[name]", with: "Default"
        expect(page).to have_field "tax_category[tax_code]", with: "ABC123"
        expect(page).to have_field "tax_category[description]", with: "Description"
        expect(page).to have_checked_field "tax_category[is_default]"

        fill_in "tax_category[name]", with: "New Age Default"
        fill_in "tax_category[tax_code]", with: "NEWCODE"
        fill_in "tax_category[description]", with: "New description"
        uncheck "tax_category[is_default]"

        click_icon :check
      end

      expect(page).to have_content "Updated successfully"

      within "#spree_tax_category_#{tax_category.id}" do
        expect(page).to have_field "tax_category[name]", with: "New Age Default"
        expect(page).to have_field "tax_category[tax_code]", with: "NEWCODE"
        expect(page).to have_field "tax_category[description]", with: "New description"
        expect(page).to have_no_checked_field "tax_category[is_default]"
      end
    end
  end
end
