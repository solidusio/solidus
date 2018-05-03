require 'spec_helper'

describe 'Promotion Categories', type: :feature do
  stub_authorization!

  context "index" do
    before do
      create(:promotion_category, name: 'name1', code: 'code1')
      create(:promotion_category, name: 'name2', code: 'code2')
      visit spree.admin_promotion_categories_path
    end

    context "listing promotion categories" do
      it "should list the existing promotion categories" do
        within_row(1) do
          expect(column_text(1)).to eq("name1")
          expect(column_text(2)).to eq("code1")
        end

        within_row(2) do
          expect(column_text(1)).to eq("name2")
          expect(column_text(2)).to eq("code2")
        end
      end
    end
  end

  context "create" do
    before do
      visit spree.admin_promotion_categories_path
      click_on "New Promotion Category"
    end

    it "should allow an admin to create a new promotion category" do
      fill_in "promotion_category_name", with: "promotion test"
      fill_in "promotion_category_code", with: "prtest"
      click_button "Create"
      expect(page).to have_content("successfully created!")
    end

    it "should not allow admin to create promotion category when invalid data" do
      fill_in "promotion_category_name", with: ""
      fill_in "promotion_category_code", with: "prtest"
      click_button "Create"
      expect(page).to have_content("Name can't be blank")
    end
  end

  context "edit" do
    before(:each) do
      create(:promotion_category, name: 'name1')
      visit spree.admin_promotion_categories_path
      within_row(1) { click_icon :edit }
    end

    it "should allow an admin to edit an existing promotion category" do
      fill_in "promotion_category_name", with: "name 99"
      click_button "Update"
      expect(page).to have_content("successfully updated!")
      expect(page).to have_content("name 99")
    end

    it "should show validation errors" do
      fill_in "promotion_category_name", with: ""
      click_button "Update"
      expect(page).to have_content("Name can't be blank")
    end
  end

  context "delete" do
    before(:each) do
      create(:promotion_category, name: 'name1')
      visit spree.admin_promotion_categories_path
    end

    it "should allow an admin to delete an existing promotion category", js: true do
      accept_alert do
        click_icon :trash
      end
      expect(page).to have_content("successfully removed!")
    end
  end
end
