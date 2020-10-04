# frozen_string_literal: true

require 'spec_helper'

describe 'Promotions', type: :feature do
  stub_authorization!
  let!(:reimbursement) { create(:reimbursement) }

  it "should display the reimbursements table" do
    visit spree.admin_order_reimbursement_path(reimbursement.order, reimbursement)
    expect(page).to have_css('table thead tr th', text: 'Product')
    expect(page).to have_css('table thead tr th', text: 'Preferred Reimbursement Type')
    expect(page).to have_css('table thead tr th', text: 'Reimbursement Type Override')
    expect(page).to have_css('table thead tr th', text: 'Exchange For')
    expect(page).to have_css('table thead tr th', text: 'Amount Before Sales Tax')
    expect(page).to have_css('table thead tr th', text: 'Total')
  end
end
