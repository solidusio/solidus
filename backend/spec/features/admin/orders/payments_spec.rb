require 'spec_helper'

describe 'Payments', type: :feature do
  stub_authorization!

  context "with a pre-existing payment" do
    let!(:payment) do
      create(:payment,
        order:          order,
        amount:         order.outstanding_balance,
        payment_method: create(:credit_card_payment_method),
        state:          state
      )
    end

    let(:order) { create(:completed_order_with_totals, number: 'R100', line_items_price: 50) }
    let(:state) { 'checkout' }

    before do
      visit "/admin/orders/#{order.number}/payments"
    end

    # Regression tests for https://github.com/spree/spree/issues/1453
    context 'with a check payment' do
      let(:order) { create(:completed_order_with_totals, number: 'R100') }
      let!(:payment) do
        create(:payment,
          order:          order,
          amount:         order.outstanding_balance,
          payment_method: create(:check_payment_method) # Check
        )
      end

      it 'capturing a check payment from a new order' do
        click_icon(:capture)
        expect(page).not_to have_content('Cannot perform requested operation')
        expect(page).to have_content('Payment Updated')
      end

      it 'voids a check payment from a new order' do
        click_icon(:void)
        expect(page).to have_content('Payment Updated')
      end
    end

    it 'should list all captures for a payment' do
      capture_amount = order.outstanding_balance / 2 * 100
      payment.capture!(capture_amount)

      visit spree.admin_order_payment_path(order, payment)
      expect(page).to have_content 'Capture Events'
      # within '#capture_events' do
      within_row(1) do
        expect(page).to have_content(capture_amount / 100)
      end
      # end
    end

    it 'displays the address for a credit card when present' do
      payment.source.update!(address: create(:address, address1: 'my cc address'))
      visit spree.admin_order_payment_path(order, payment)
      expect(page).to have_content 'my cc address'
    end

    it 'lists and create payments for an order', js: true do
      within_row(1) do
        expect(column_text(3)).to eq('$150.00')
        expect(column_text(4)).to eq('Credit Card')
        expect(column_text(6)).to eq('checkout')
      end

      click_icon :void
      expect(page).to have_css('#payment_status', text: 'balance due')
      expect(page).to have_content('Payment Updated')

      within_row(1) do
        expect(column_text(3)).to eq('$150.00')
        expect(column_text(4)).to eq('Credit Card')
        expect(column_text(6)).to eq('void')
      end

      click_on 'New Payment'
      expect(page).to have_content('New Payment')
      click_button 'Update'
      expect(page).to have_content('successfully created!')

      click_icon(:capture)

      expect(page).to have_selector('#payment_status', text: 'paid')
      expect(page).not_to have_selector('#new_payment_section')
    end

    # Regression test for https://github.com/spree/spree/issues/1269
    it 'cannot create a payment for an order with no payment methods' do
      Spree::PaymentMethod.delete_all
      order.payments.delete_all

      click_on 'New Payment'
      expect(page).to have_content('You cannot create a payment for an order without any payment methods defined.')
      expect(page).to have_content('Please define some payment methods first.')
    end

    context 'payment is pending', js: true do
      let(:state) { 'pending' }

      it 'allows the amount to be edited by clicking on the edit button then saving' do
        within_row(1) do
          click_icon(:edit)
          fill_in('amount', with: '$1')
          click_icon(:save)
          expect(page).to have_selector('td.amount span', text: '$1.00')
          expect(payment.reload.amount).to eq(1.00)
        end
      end

      it 'allows the amount to be edited by clicking on the amount then saving' do
        within_row(1) do
          find('td.amount span').click
          fill_in('amount', with: '$1.01')
          click_icon(:save)
          expect(page).to have_selector('td.amount span', text: '$1.01')
          expect(payment.reload.amount).to eq(1.01)
        end
      end

      it 'allows the amount change to be cancelled by clicking on the cancel button' do
        within_row(1) do
          click_icon(:edit)

          # Can't use fill_in here, as under poltergeist that will unfocus (and
          # thus submit) the field under poltergeist
          find('td.amount input').click
          page.execute_script("$('td.amount input').val('$1')")

          click_icon(:cancel)
          expect(page).to have_selector('td.amount span', text: '$150.00')
          expect(payment.reload.amount).to eq(150.00)
        end
      end

      it 'displays an error when the amount is invalid' do
        within_row(1) do
          click_icon(:edit)
          fill_in('amount', with: 'invalid')
          click_icon(:save)
        end
        expect(page).to have_selector('.flash.error', text: 'Invalid resource. Please fix errors and try again.')
        expect(page).to have_field('amount', with: 'invalid')
        expect(payment.reload.amount).to eq(150.00)
      end
    end

    context 'payment is completed', js: true do
      let(:state) { 'completed' }

      it 'does not allow the amount to be edited' do
        within_row(1) do
          expect(page).not_to have_selector('.fa-edit')
        end
      end
    end
  end

  context "with no prior payments" do
    let(:order) { create(:order_with_line_items, line_items_count: 1) }
    let!(:payment_method) { create(:credit_card_payment_method) }

    # Regression tests for https://github.com/spree/spree/issues/4129
    context "with a credit card payment method" do
      before do
        visit spree.admin_order_payments_path(order)
      end

      it "is able to create a new credit card payment with valid information", js: true do
        fill_in "Card Number", with: "4111 1111 1111 1111"
        fill_in "Name", with: "Test User"
        fill_in "Expiration", with: "09 / #{Time.current.year + 1}"
        fill_in "Card Code", with: "007"
        # Regression test for https://github.com/spree/spree/issues/4277
        expect(page).to have_css('.ccType[value="visa"]', visible: false)
        click_button "Continue"
        expect(page).to have_content("Payment has been successfully created!")
      end

      it "is unable to create a new payment with invalid information" do
        click_button "Continue"
        expect(page).to have_content("Payment could not be created.")
        expect(page).to have_content("Number can't be blank")
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_content("Verification Value can't be blank")
        expect(page).to have_content("Month is not a number")
        expect(page).to have_content("Year is not a number")
      end
    end

    context "user existing card" do
      let!(:cc) do
        create(:credit_card, user_id: order.user_id, payment_method: payment_method, gateway_customer_profile_id: "BGS-RFRE")
      end

      before { visit spree.admin_order_payments_path(order) }

      it "is able to reuse customer payment source" do
        expect(find("#card_#{cc.id}")).to be_checked
        click_button "Continue"
        expect(page).to have_content("Payment has been successfully created!")
      end
    end

    context "with a check" do
      let(:order) { create(:completed_order_with_totals, line_items_count: 1) }
      let!(:payment_method) { create(:check_payment_method) }

      before do
        visit spree.admin_order_payments_path(order.reload)
      end

      it "can successfully be created and captured" do
        click_on 'Update'
        expect(page).to have_content("Payment has been successfully created!")
        click_icon(:capture)
        expect(page).to have_content("Payment Updated")
      end
    end

    context 'with a soft-deleted payment method' do
      let(:order) { create(:completed_order_with_totals, line_items_count: 1) }
      let!(:payment_method) { create(:check_payment_method) }
      let!(:payment) do
        create(:payment,
          order:          order,
          amount:         order.outstanding_balance,
          payment_method: payment_method
        )
      end

      before do
        payment_method.destroy
        visit spree.admin_order_payments_path(order.reload)
      end

      it "can list and view the payment" do
        expect(page).to have_content(payment.number)
        click_on payment.number
        expect(page).to have_current_path("/admin/orders/#{order.number}/payments/#{payment.id}")
        expect(page).to have_content(payment.amount)
      end
    end
  end

  # Previously this would fail unless the method was named "Credit Card"
  context "with an differently named payment method" do
    let(:order) { create(:order_with_line_items, line_items_count: 1) }
    let!(:chequing_payment_method) { create(:check_payment_method) }
    let!(:payment_method) { create(:credit_card_payment_method, name: "Multipass!") }

    before do
      visit spree.admin_order_payments_path(order.reload)
    end

    it "is able to create a new payment", js: true do
      choose payment_method.name
      fill_in "Card Number", with: "4111 1111 1111 1111"
      fill_in "Name", with: "Test User"
      fill_in "Expiration", with: "09 / #{Time.current.year + 1}"
      fill_in "Card Code", with: "007"
      click_button "Continue"
      expect(page).to have_content("Payment has been successfully created!")
    end
  end

  context "when required quantity is more than available" do
    let(:product) { create(:product_not_backorderable) }

    let(:order) do
      create(:order_with_line_items, {
        line_items_count: 1,
        line_items_attributes: [{ quantity: 11, product: product }],
        stock_location: product.master.stock_locations.first
      })
    end

    let!(:chequing_payment_method) { create(:check_payment_method) }
    let!(:payment_method) { create(:credit_card_payment_method, name: "Multipass!") }

    before do
      visit spree.admin_order_payments_path(order.reload)
    end

    it "displays an error" do
      choose payment_method.name
      fill_in "Card Number", with: "4111 1111 1111 1111"
      fill_in "Name", with: "Test User"
      fill_in "Expiration", with: "09 / #{Time.current.year + 1}"
      fill_in "Card Code", with: "007"
      click_button "Continue"
      expect(page).to have_content Spree.t(:insufficient_stock_for_order)
    end
  end
end
