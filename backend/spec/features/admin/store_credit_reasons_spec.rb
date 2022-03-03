# frozen_string_literal: true

require "spec_helper"

describe "Store credit reasons", type: :feature do
  stub_authorization!

  let!(:store_credit_reason) { create(:store_credit_reason) }

  before { visit spree.admin_store_credit_reasons_path }

  it "lists store credit reasons" do
    expect(page).to have_content store_credit_reason.name
  end

  context "when the user can create new store credit reasons" do
    custom_authorization! do |_user|
      can :create, Spree::StoreCreditReason
    end

    it "shows the `New Store credit reason` button" do
      expect(page).to have_content "New Store Credit Reason"
    end
  end

  context "when the user cannot create new store credit reasons" do
    custom_authorization! do |_user|
      cannot :create, Spree::StoreCreditReason
    end


    it "doesnt show the `New Store credit reason` button" do
      expect(page).not_to have_content "New Store Credit Reason"
    end
  end
end
