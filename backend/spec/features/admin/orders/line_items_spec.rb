# frozen_string_literal: true

require "spec_helper"

# Tests for https://github.com/spree/spree/issues/3958's features
describe "Order Line Items", type: :feature, js: true do
  stub_authorization!

  before do
    # Removing the delivery step causes the order page to render a different
    # partial, called _line_items, which shows line items rather than shipments
    allow(Spree::Order).to receive_messages checkout_step_names: [:address, :payment, :confirm, :complete]
  end

  let!(:order) do
    order = create(:order_with_line_items, line_items_count: 1)
    order.shipments.destroy_all
    order
  end

  it "can edit a line item's quantity" do
    visit spree.cart_admin_order_path(order)
    within(".line-items") do
      find(".edit-line-item").click
      fill_in "quantity", with: 10
      find(".save-line-item").click
    end
    within ".line-item-qty-show" do
      expect(page).to have_content("10")
    end
    within ".line-item-total" do
      expect(page).to have_content("$100.00")
    end
  end

  it "can delete a line item" do
    visit spree.cart_admin_order_path(order)

    product_name = find(".line-items tr:nth-child(1) .line-item-name").text

    within(".line-items") do
      within_row(1) do
        accept_alert do
          find(".delete-line-item").click
        end
      end
    end

    expect(find("#order_total")).to have_content("$0.00")
    expect(page).not_to have_content(product_name)
  end
end
