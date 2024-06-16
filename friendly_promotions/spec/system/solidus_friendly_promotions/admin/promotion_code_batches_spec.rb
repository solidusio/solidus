# frozen_string_literal: true

require "spec_helper"

RSpec.feature "Promotion Code Batches", partial_double_verification: false do
  stub_authorization!

  describe "create" do
    let(:promotion) { create :friendly_promotion }

    before do
      allow_any_instance_of(ApplicationController).to receive(:spree_current_user) { build(:user, id: 123) }
      visit solidus_friendly_promotions.new_admin_promotion_promotion_code_batch_path(promotion)
    end

    def create_code_batch
      fill_in "Base code", with: "base"
      fill_in "Number of codes", with: 3
      click_button "Create"
    end

    it "renders partial without 'Per code usage limit' " do
      expect(page).to_not have_field("promotion_per_code_usage_limit")
    end

    it "creates a new promotion code batch and disables the submit button", :js do
      create_code_batch

      expect(page).to have_content "Code batch has been successfully created!"

      visit solidus_friendly_promotions.new_admin_promotion_promotion_code_batch_path(promotion)

      page.execute_script <<~JS
        document.querySelectorAll('form').forEach(function(element) {
          addEventListener('submit', function(element) {
            element.preventDefault();
          })
        });
      JS

      create_code_batch

      expect(page).to have_button("Create", disabled: true)
    end
  end
end
