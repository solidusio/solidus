# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'New Refund creation', :js do
  stub_authorization!

  let(:order) { create :order_ready_to_ship }
  let(:payment) { order.payments.first }
  let(:amount) { '10.99' }
  let!(:reason) { create :refund_reason }

  it 'creates a new refund' do
    visit spree.new_admin_order_payment_refund_path(order, payment)
    expect(page).not_to have_selector 'td', text: amount
    within '.new_refund' do
      fill_in 'refund_amount', with: amount
      select reason.name, from: 'Reason'
      click_button 'Refund'
    end
    expect(page).to have_content 'Refund has been successfully created!'
    within 'tr[data-hook="refunds_row"]' do
      expect(page).to have_selector 'td', text: amount
    end
  end

  it 'creates a new log entry for a refund', pending: 'This is pending because currently no log entry is created for this refund.' do
    visit spree.new_admin_order_payment_refund_path(order, payment)
    expect(page).not_to have_selector 'td', text: amount
    within '.new_refund' do
      fill_in 'refund_amount', with: amount
      select reason.name, from: 'Reason'
      click_button 'Refund'
    end
    expect(page).to have_content 'Refund has been successfully created!'
    within 'tr[data-hook="payments_row"]' do
      payment_number = find_all('td').first.text
      click_on payment_number
      expect(page).to have_selector 'tr.log_entry'
    end
  end

  it 'disables the button at submit' do
    visit spree.new_admin_order_payment_refund_path(order, payment)
    page.execute_script "$('form').submit(function(e) { e.preventDefault()})"
    within '.new_refund' do
      fill_in 'refund_amount', with: amount
      select reason.name, from: 'Reason'
      click_button 'Refund'
      expect(page).to have_button('Refund', disabled: true)
    end
  end
end
