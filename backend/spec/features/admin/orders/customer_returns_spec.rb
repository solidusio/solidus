# frozen_string_literal: true

require "spec_helper"

describe "Customer returns", type: :feature do
  stub_authorization!

  def create_customer_return(value)
    find("#select-all").click
    page.execute_script "$('select.add-item').val(#{value.to_s.inspect})"
    select "NY Warehouse", from: "Stock Location"
    click_button "Create"
  end

  def expect_order_state_label_to_eq(text)
    within("dd.order-state") { expect(page).to have_content(text) }
  end

  before do
    visit spree.new_admin_order_customer_return_path(order)
  end

  context "when the order has more than one line item" do
    let(:order) { create :shipped_order, line_items_count: 2 }

    context 'when creating a return with state "Received"' do
      it "marks the order as returned", :js, :flaky do
        create_customer_return("receive")

        expect(page).to have_content "Customer Return has been successfully created"

        expect_order_state_label_to_eq("Returned")
      end
    end

    it "disables the button at submit" do
      expect(page).to have_css('input[type="submit"][data-disable-with="Create"]')
    end

    context 'when creating a return with state "In Transit" and then marking it as "Received"' do
      it 'disables the "Receive" button at submit', :js do
        create_customer_return("in_transit")
        expect(page).to have_css('input[type="submit"][data-disable-with="Receive"]')
      end

      it "marks the order as returned", :js do
        create_customer_return("in_transit")
        expect(page).to have_content "Customer Return has been successfully created"
        expect_order_state_label_to_eq("Complete")

        within('[data-hook="rejected_return_items"] tbody tr:nth-child(1)') { click_button("Receive") }
        expect_order_state_label_to_eq("Complete")

        within('[data-hook="rejected_return_items"] tbody') { click_button("Receive") }
        expect_order_state_label_to_eq("Returned")
      end
    end
  end

  context "when the order has only one line item" do
    let(:order) { create :shipped_order, line_items_count: 1 }

    context 'when creating a return with state "Received"' do
      it "marks the order as returned", :js do
        create_customer_return("receive")

        expect(page).to have_content "Customer Return has been successfully created"
        expect_order_state_label_to_eq("Returned")
      end
    end

    context 'when creating a return with state "In Transit" and then marking it as "Received"' do
      it "marks the order as returned", :js do
        create_customer_return("in_transit")
        expect(page).to have_content "Customer Return has been successfully created"
        expect_order_state_label_to_eq("Complete")

        within('[data-hook="rejected_return_items"] tbody tr:nth-child(1)') { click_button("Receive") }
        expect_order_state_label_to_eq("Returned")
      end
    end
  end
end
