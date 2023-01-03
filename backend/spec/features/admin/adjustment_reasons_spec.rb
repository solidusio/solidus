# frozen_string_literal: true

require 'spec_helper'

describe "Adjustment reasons", type: :feature do
  stub_authorization!

  context "when visiting the list page" do
    let!(:adjustment_reason) { create(:adjustment_reason) }

    before { visit spree.admin_adjustment_reasons_path }

    context "when the user cannot create adjustment reasons" do
      custom_authorization! do |_user|
        cannot :create, Spree::AdjustmentReason
      end

      it "doesn't show the `New Adjustment Reason` button" do
        expect(page).not_to have_content "New Adjustment Reason"
      end
    end

    context "when the user can create adjustment reasons" do
      custom_authorization! do |_user|
        can :create, Spree::AdjustmentReason
      end

      it "shows the 'New Adjustment Reason' button" do
        expect(page).to have_content "New Adjustment Reason"
      end
    end

    context "when the user cannot edit adjustment reasons" do
      custom_authorization! do |_user|
        cannot :edit, Spree::AdjustmentReason
      end

      it "lists reasons but doesn't show their edit buttons" do
        within '#listing_adjustment_reasons' do
          expect(page).to have_content adjustment_reason.name
          expect(page).not_to have_selector('a[data-action="edit"]')
        end
      end
    end

    context "when the user can edit adjustment reasons" do
      custom_authorization! do |_user|
        can :edit, Spree::AdjustmentReason
      end

      it "lists reasons and their edit buttons" do
        within '#listing_adjustment_reasons' do
          expect(page).to have_content adjustment_reason.name
          expect(page).to have_selector('a[data-action="edit"]')
        end
      end
    end
  end
end

