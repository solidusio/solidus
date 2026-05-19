# frozen_string_literal: true

require "spec_helper"

describe "Log entries", type: :feature do
  stub_authorization!

  let!(:payment) { create(:payment) }

  context "with a successful log entry" do
    before do
      response = ActiveMerchant::Billing::Response.new(
        true,
        "Transaction successful",
        transid: "ABCD1234"
      )

      payment.log_entries.create(
        details: response.to_yaml
      )
    end

    it "shows a successful attempt" do
      visit spree.admin_order_payments_path(payment.order)
      click_on payment.number

      within("#listing_log_entries") do
        expect(page).to have_content("Transaction successful")
      end
    end
  end

  context "with a failed log entry" do
    before do
      response = ActiveMerchant::Billing::Response.new(
        false,
        "Transaction failed",
        transid: "ABCD1234"
      )

      payment.log_entries.create(
        source: payment.source,
        details: response.to_yaml
      )
    end

    it "shows a failed attempt" do
      visit spree.admin_order_payments_path(payment.order)
      click_on payment.number

      within("#listing_log_entries") do
        expect(page).to have_content("Transaction failed")
      end
    end
  end

  context "with a log entry belonging to a refund of the payment" do
    let!(:payment) { create(:payment, amount: 100) }
    let!(:refund) { create(:refund, payment: payment, amount: 10) }

    before do
      response = ActiveMerchant::Billing::Response.new(
        true,
        "Refund processed",
        transid: "REFUND-1"
      )

      refund.log_entries.create!(details: response.to_yaml)
    end

    it "shows the refund entry on the payment page with 'Refund' as its source" do
      visit spree.admin_order_payments_path(payment.order)
      click_on payment.number

      within("#listing_log_entries") do
        expect(page).to have_content("Refund processed")
        expect(page).to have_content("Refund")
      end
    end
  end
end
