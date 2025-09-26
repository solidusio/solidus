# frozen_string_literal: true

require "spec_helper"

describe "ReturnAuthorizations", type: :feature do
  include OrderFeatureHelper

  stub_authorization!

  let!(:order) { create(:shipped_order) }

  context "when the user cannot manage return authorizations" do
    custom_authorization! do |_user|
      cannot :manage, Spree::ReturnAuthorization
      can [:read, :admin], Spree::ReturnAuthorization
    end

    before do
      visit spree.admin_order_return_authorizations_path(order)
    end

    it "does not show the link for creating new RMAs" do
      within "#content-header" do
        expect(page).not_to have_content "New RMA"
      end
    end
  end

  context "when the user can manage return authorizations" do
    describe "create", :js do
      def create_return_authorization
        find("#select-all").click
        select "NY Warehouse", from: "Stock Location"
        click_button "Create"
      end

      before do
        visit spree.new_admin_order_return_authorization_path(order)
      end

      it "creates a return authorization" do
        create_return_authorization

        expect(page).to have_content "Return Authorization has been successfully created!"
      end

      it "automatically checks edited rows" do
        expect do
          find(".refund-amount-input").native.send_keys [1, :tab]
        end.to change { find(".add-item").checked? }.from(false).to(true)
      end

      it "disables the button at submit" do
        page.execute_script "$('form').submit(function(e) { e.preventDefault()})"

        create_return_authorization

        expect(page).to have_button("Create", disabled: true)
      end
    end

    describe "when a return authorization exists" do
      let!(:return_authorization) { create(:return_authorization, order:) }

      it "can visit the return authorizations list page" do
        visit spree.admin_order_return_authorizations_path(order)
      end

      describe "edit" do
        it "can visit the return authorizations edit page" do
          visit spree.edit_admin_order_return_authorization_path(order, return_authorization)
        end

        it "return authorizations edit page has a data hook for extensions to add content above, below or within the RA form" do
          visit spree.edit_admin_order_return_authorization_path(order, return_authorization)
          expect(page).to have_selector("[data-hook=return-authorization-form-wrapper]")
        end
      end
    end
  end
end
