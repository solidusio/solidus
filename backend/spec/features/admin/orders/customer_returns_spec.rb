# frozen_string_literal: true

require 'spec_helper'

describe 'Customer returns', type: :feature do
  stub_authorization!

  context 'when the order has more than one line item' do
    let(:order) { create :shipped_order, line_items_count: 2 }

    def create_customer_return
      find('#select-all').click
      page.execute_script "$('select.add-item').val('receive')"
      select 'NY Warehouse', from: 'Stock Location'
      click_button 'Create'
    end

    before do
      visit spree.new_admin_order_customer_return_path(order)
    end

    context 'when creating a return with state "Received"' do
      it 'marks the order as returned', :js do
        create_customer_return

        expect(page).to have_content 'Customer Return has been successfully created'
        within 'dd.order-state' do
          expect(page).to have_content 'Returned'
        end
      end
    end

    it 'disables the button at submit', :js do
      page.execute_script "$('form').submit(function(e) { e.preventDefault()})"

      create_customer_return

      expect(page).to have_button("Create", disabled: true)
    end
  end
end
