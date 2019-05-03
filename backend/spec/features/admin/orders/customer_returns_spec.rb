# frozen_string_literal: true

require 'spec_helper'

describe 'Customer returns', type: :feature do
  stub_authorization!

  context 'when the order has more than one line item' do
    let(:order) { create :shipped_order, line_items_count: 2 }

    context 'when creating a return with state "Received"' do
      it 'marks the order as returned', :js do
        visit spree.new_admin_order_customer_return_path(order)

        find('#select-all').click
        page.execute_script "$('select.add-item').val('receive')"
        select 'NY Warehouse', from: 'Stock Location'
        click_button 'Create'

        expect(page).to have_content 'Customer Return has been successfully created'

        within 'dd.order-state' do
          expect(page).to have_content 'Returned'
        end
      end
    end
  end
end
