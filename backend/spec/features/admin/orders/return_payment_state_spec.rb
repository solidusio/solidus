# frozen_string_literal: true

require "spec_helper"

describe "Return payment state spec" do
  stub_authorization!

  before do
    Spree::RefundReason.create!(name: Spree::RefundReason::RETURN_PROCESSING_REASON, mutable: false)
    allow_any_instance_of(Spree::Admin::ReimbursementsController).to receive(:spree_current_user)
      .and_return(user)
  end

  let!(:order) { create(:shipped_order) }
  let(:user) { create(:admin_user) }

  def create_customer_return
    # From an order with a shipped shipment
    visit "/admin/orders/#{order.number}/edit"

    # Create a Return Authorization (select the Original Reimbursement type)
    click_on "RMA"
    click_on "New RMA"

    find(".add-item").click # check first (and only) item
    select Spree::StockLocation.first.name, from: "return_authorization[stock_location_id]", visible: false
    click_on "Create"

    # Create a Customer Return (select the item from 'Items in Return Authorizations')
    click_on "Customer Returns"
    click_on "New Customer Return"

    find("input.add-item").click # check first (and only) item
    select "Received", from: "customer_return[return_items_attributes][0][reception_status_event]", visible: false
    select Spree::StockLocation.first.name, from: "customer_return[stock_location_id]", visible: false
    click_on "Create"
  end

  # Regression test for https://github.com/spree/spree/issues/6229
  it "refunds and has outstanding_balance of zero", js: true do
    expect(order).to have_attributes(
      total: 110,
      refund_total: 0,
      payment_total: 110,
      outstanding_balance: 0,
      payment_state: "paid"
    )

    create_customer_return

    # Create reimbursement
    click_on "Create reimbursement"

    # Reimburse.
    click_on "Reimburse"

    expect(page).to have_css("tr.reimbursement-refund")

    order.reload

    expect(order).to have_attributes(
      total: 110,
      refund_total: 10,
      payment_total: 100,
      outstanding_balance: 0,
      payment_state: "paid"
    )
  end

  it 'disables the "Create Reimbursement" button at submit', :js do
    create_customer_return

    page.execute_script "$('form').submit(function(e) { e.preventDefault()})"

    # Create reimbursement
    click_on "Create reimbursement"

    expect(page).to have_button("Create reimbursement", disabled: true)
  end
end
