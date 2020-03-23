# frozen_string_literal: true

require "spec_helper"

feature "Promotion Code Batches", partial_double_verification: false do
  stub_authorization!

  describe "create" do
    let(:promotion) { create :promotion }

    before do
      user = double.as_null_object
      allow_any_instance_of(ActionView::Base).to receive(:spree_current_user) { user }
      visit spree.new_admin_promotion_promotion_code_batch_path(promotion)
    end

    def create_code_batch
      fill_in "Base code", with: "base"
      fill_in "Number of codes", with: 3
      click_button "Create"
    end

    it "creates a new promotion code batch and disables the submit button", :js do
      create_code_batch

      expect(page).to have_content "Promotion Code Batch has been successfully created!"

      visit spree.new_admin_promotion_promotion_code_batch_path(promotion)

      page.execute_script "$('form').submit(function(e) { e.preventDefault()})"

      create_code_batch

      expect(page).to have_button("Create", disabled: true)
    end
  end
end
