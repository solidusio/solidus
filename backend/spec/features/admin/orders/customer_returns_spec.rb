# frozen_string_literal: true

require 'spec_helper'

describe 'Customer returns', type: :feature do
  stub_authorization!

  def create_customer_return(value)
    find('#select-all').click
    page.execute_script "$('select.add-item').val(#{value.to_s.inspect})"
    select 'NY Warehouse', from: 'Stock Location'
    click_button 'Create'
  end

  def order_state_label
    find('dd.order-state').text
  end

  before do
    allow(Spree::Deprecation).to receive(:warn) do |message|
      expect(message).to match('#process_inventory_unit! will not call')
    end

    visit spree.new_admin_order_customer_return_path(order)
  end

  context 'when the order has more than one line item' do
    let(:order) { create :shipped_order, line_items_count: 2 }

    context 'when creating a return with state "Received"' do
      it 'marks the order as returned', :js do
        create_customer_return('receive')

        expect(page).to have_content 'Customer Return has been successfully created'

        expect(order_state_label).to eq('Returned')
      end
    end

    it 'disables the button at submit', :js do
      page.execute_script "$('form').submit(function(e) { e.preventDefault()})"

      create_customer_return('receive')

      expect(page).to have_button("Create", disabled: true)
    end

    context 'when creating a return with state "In Transit" and then marking it as "Received"' do
      it 'marks the order as returned', :js do
        create_customer_return('in_transit')
        expect(page).to have_content 'Customer Return has been successfully created'
        expect(order_state_label).to eq('Complete')

        within('[data-hook="rejected_return_items"] tbody tr:nth-child(1)') { click_button('Receive') }
        expect(order_state_label).to eq('Complete')

        within('[data-hook="rejected_return_items"] tbody tr:nth-child(2)') { click_button('Receive') }
        expect(order_state_label).to eq('Returned')
      end
    end
  end

  context 'when the order has only one line item' do
    let(:order) { create :shipped_order, line_items_count: 1 }

    context 'when creating a return with state "Received"' do
      it 'marks the order as returned', :js do
        create_customer_return('receive')

        expect(page).to have_content 'Customer Return has been successfully created'
        expect(order_state_label).to eq('Returned')
      end
    end

    context 'when creating a return with state "In Transit" and then marking it as "Received"' do
      it 'marks the order as returned', :js do
        create_customer_return('in_transit')
        expect(page).to have_content 'Customer Return has been successfully created'
        expect(order_state_label).to eq('Complete')

        within('[data-hook="rejected_return_items"] tbody tr:nth-child(1)') { click_button('Receive') }
        expect(order_state_label).to eq('Returned')
      end
    end
  end
end
