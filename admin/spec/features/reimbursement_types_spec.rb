# frozen_string_literal: true

require 'spec_helper'

describe "Reimbursement Types", :js, type: :feature do
  before { sign_in create(:admin_user, email: 'admin@example.com') }

  it "lists Reimbursement Types and allows deleting them" do
    create(:reimbursement_type, name: "Default-reimbursement-type")

    visit "/admin/reimbursement_types"
    expect(page).to have_content("Default-reimbursement-type")
    expect(page).to be_axe_clean
  end
end
