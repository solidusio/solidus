# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Checkout', :js, type: :system do
  include  SolidusStarterFrontend::System::CheckoutHelpers

  include_context 'checkout setup'

  context "visitor makes checkout as guest without registration" do
    before(:each) do
      stock_location.stock_items.update_all(count_on_hand: 1)
    end

    context "defaults to use billing address" do
      before do
        add_mug_to_cart
        Spree::Order.last.update_column(:email, "test@example.com")
        click_button "Checkout"
      end

      it 'should default checkbox to checked', js: true do
        expect(find('input#order_use_billing')).to be_checked
      end

      it "should remain checked when used and visitor steps back to address step", js: true do
        fill_in_address
        expect(find('input#order_use_billing')).to be_checked
      end
    end

    # Regression test for https://github.com/spree/spree/issues/4079
    context "persists state when on address page" do
      before do
        add_mug_to_cart
        checkout_as_guest
        expect(page).to have_content("Billing Address")
      end

      it 'goes to address state', js: true do
        expect(Spree::Order.count).to eq(1)
        expect(Spree::Order.last.state).to eq("address")
      end
    end

    # Regression test for https://github.com/spree/spree/issues/1596
    context "full checkout" do
      before do
        shipping_method.calculator.update!(preferred_amount: 10)
        mug.shipping_category = shipping_method.shipping_categories.first
        mug.save!
      end

      it "does not break the per-item shipping method calculator", js: true do
        add_mug_to_cart
        checkout_as_guest

        fill_in "order_email", with: "test@example.com"
        fill_in_address

        click_button "Save and Continue"
        expect(page).not_to have_content("undefined method `promotion'")
        click_button "Save and Continue"
        expect(page).to have_content("Shipping total:\n$10.00")
      end
    end

    # Regression test for https://github.com/spree/spree/issues/4306
    context "free shipping" do
      before do
        add_mug_to_cart
        checkout_as_guest
      end

      it "should not show 'Free Shipping' when there are no shipments", js: true do
        within("#checkout-summary") do
          expect(page).to_not have_content('Free Shipping')
        end
      end
    end
  end

  context "displays default user addresses on address step" do
    before do
      stock_location.stock_items.update_all(count_on_hand: 1)
    end

    context "when user is logged in" do
      let!(:user) do
        create(:user, bill_address: saved_bill_address, ship_address: saved_ship_address)
      end

      let!(:order) do
        order = Spree::Order.create!(
          email: "spree@example.com",
          store: Spree::Store.first || FactoryBot.create(:store)
        )

        order.reload
        order.user = user
        order.recalculate
        order
      end

      before do
        allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
        allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
        allow_any_instance_of(CartsController).to receive_messages(spree_current_user: user)
        allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)
        allow_any_instance_of(CartLineItemsController).to receive_messages(spree_current_user: user)

        add_mug_to_cart
        click_button "Checkout"
        # We need an order reload here to get newly associated addresses.
        # Then we go back to address where we are supposed to be redirected.
        order.reload
        visit checkout_state_path(:address)
      end

      context "when user has default addresses saved" do
        let(:saved_bill_address) { create(:address, name: 'Bill Gates') }
        let(:saved_ship_address) { create(:address, name: 'Steve Jobs') }

        it 'shows the saved addresses', js: true do
          within("#billing") do
            expect(find_field('Name').value).to eq 'Bill Gates'
          end

          within("#shipping") do
            expect(find_field('Name').value).to eq 'Steve Jobs'
          end
        end
      end

      context "when user does not have default addresses saved" do
        let(:saved_bill_address) { nil }
        let(:saved_ship_address) { nil }

        it 'shows an empty address', js: true do
          within("#billing") do
            expect(find_field('Name').value).to be_blank
          end

          within("#shipping") do
            expect(find('input[name*="[name]"]', visible: :hidden).value).to be_blank
          end
        end
      end
    end

    context "when user is not logged in" do
      context "and proceeds with guest checkout" do
        it 'shows empty addresses', js: true do
          add_mug_to_cart
          checkout_as_guest

          within("#billing") do
            expect(find_field('Name').value).to be_blank
          end

          within("#shipping") do
            expect(find('input[name*="[name]"]', visible: :hidden).value).to be_blank
          end
        end
      end

      context "and proceeds logging in" do
        let!(:user) do
          create(:user, bill_address: saved_bill_address, ship_address: saved_ship_address)
        end

        before do
          add_mug_to_cart
          click_button "Checkout"

          # Simulate user login
          Spree::Order.last.associate_user!(user)
          allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
          allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)

          # Simulate redirect back to address after login
          visit checkout_state_path(:address)
        end

        context "when does not have saved addresses" do
          let(:saved_bill_address) { nil }
          let(:saved_ship_address) { nil }

          it 'shows empty addresses', js: true do
            within("#billing") do
              expect(find_field('Name').value).to be_blank
            end

            within("#shipping") do
              expect(find('input[name*="[name]"]', visible: :hidden).value).to be_blank
            end
          end
        end

        # Regression test for https://github.com/solidusio/solidus/issues/1811
        context "when does have saved addresses" do
          let(:saved_bill_address) { create(:address, name: 'Bill Gates') }
          let(:saved_ship_address) { create(:address, name: 'Steve Jobs') }

          it 'shows empty addresses', js: true do
            within("#billing") do
              expect(find_field('Name').value).to eq 'Bill Gates'
            end

            within("#shipping") do
              expect(find_field('Name').value).to eq 'Steve Jobs'
            end
          end
        end
      end
    end
  end

  context "when order has only a void payment" do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment) }

    before do
      user = create(:user)
      order.user = user
      order.recalculate

      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
    end

    it "does not allow successful order submission" do
      visit checkout_path
      order.payments.first.update state: :void
      check 'Agree to Terms of Service'
      click_button 'Place Order'
      expect(page).to have_current_path checkout_state_path(:payment)
    end
  end

  # Regression test for https://github.com/spree/spree/issues/2694 and https://github.com/spree/spree/issues/4117
  context "doesn't allow bad credit card numbers" do
    let!(:payment_method) { create(:credit_card_payment_method) }
    before(:each) do
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery)

      user = create(:user)
      order.user = user
      order.recalculate

      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
    end

    it "redirects to payment page" do
      visit checkout_state_path(:delivery)
      click_button "Save and Continue"
      choose "Credit Card"
      fill_in "Card Number", with: '123'
      fill_in "Expiration", with: '04 / 20'
      fill_in "Card Code", with: '123'
      click_button "Save and Continue"
      check 'Agree to Terms of Service'
      click_button "Place Order"
      expect(page).to have_content("Bogus Gateway: Forced failure")
      expect(page.current_url).to include("/checkout/payment")
    end
  end

  context "and likes to double click buttons" do
    let!(:user) { create(:user) }

    let!(:order) do
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery)

      order.reload
      order.user = user
      order.recalculate
      order
    end

    before(:each) do
      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
      allow_any_instance_of(CheckoutsController).to receive_messages(skip_state_validation?: true)
    end

    it "prevents double clicking the payment button on checkout", js: true do
      visit checkout_state_path(:payment)

      # prevent form submit to verify button is disabled
      page.execute_script("document.getElementById('checkout_form_payment').onsubmit = function(){return false;}")

      expect(page).not_to have_selector('button[disabled]')
      click_button "Save and Continue"
      expect(page).to have_selector('button[disabled]')
    end

    it "prevents double clicking the confirm button on checkout", js: true do
      order.payments << create(:payment)
      visit checkout_state_path(:confirm)

      # Test TOS not checked alert
      accept_alert('Please review and accept the Terms of Service') { click_button "Place Order" }

      # prevent form submit to verify button is disabled
      page.execute_script("document.getElementById('checkout_form_confirm').onsubmit = function(){return false;}")

      check 'Agree to Terms of Service'
      click_button "Place Order"
      button = find('button.button-primary')
      expect(button).to be_disabled
    end
  end

  context "when the order is fully covered by store credit" do
    before do
      create(:store_credit_payment_method)
      credit_card_payment_method = create(:credit_card_payment_method)
      check_payment_method = create(:check_payment_method)

      user = create(:user)
      create(:store_credit, user: user)
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:payment, user: user)

      allow(order).to receive_messages(available_payment_methods: [check_payment_method, credit_card_payment_method])
      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: order.user)
    end

    it "allows the user to complete checkout using only store credit as the payment source" do
      visit checkout_state_path(:payment)

      expect(page).to have_content("Your order is fully covered by store credits, no additional payment method is required.")
      expect(page).not_to match(/\bCheck\b/)
      expect(page).not_to match(/\bCredit Card\b/)

      click_button "Save and Continue"
      expect(page).to have_content("Confirm")

      check "Agree to Terms of Service"
      click_on "Place Order"
      expect(page).to have_content(I18n.t('spree.order_processed_successfully'))
    end
  end

  context "when several payment methods are available" do
    let(:credit_card_payment) { create(:credit_card_payment_method) }
    let(:check_payment) { create(:check_payment_method) }

    it "disables the details of other payment methods", js: true do
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery)
      allow(order).to receive_messages(available_payment_methods: [check_payment, credit_card_payment])
      order.user = create(:user)
      order.recalculate

      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: order.user)

      visit checkout_state_path(:payment)

      # Starts off with the first payment method being selected
      expect(find_payment_radio(check_payment.id)).to be_checked
      expect(find_payment_fieldset(check_payment.id)).not_to be_disabled

      expect(find_payment_radio(credit_card_payment.id)).not_to be_checked
      expect(find_payment_fieldset(credit_card_payment.id)).to be_disabled

      # Select the credit card
      find_payment_radio(credit_card_payment.id).click

      expect(find_payment_radio(check_payment.id)).not_to be_checked
      expect(find_payment_fieldset(check_payment.id)).to be_disabled

      expect(find_payment_radio(credit_card_payment.id)).to be_checked
      expect(find_payment_fieldset(credit_card_payment.id)).not_to be_disabled
    end
  end

  context "user has payment sources", js: true do
    before { Spree::PaymentMethod.all.each(&:destroy) }
    let!(:bogus) { create(:credit_card_payment_method) }
    let(:user) { create(:user) }

    let!(:credit_card) do
      create(:credit_card, user_id: user.id, payment_method: bogus, gateway_customer_profile_id: "BGS-WEFWF")
    end

    let!(:wallet_source) { user.wallet.add(credit_card) }

    before do
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery, user: user)

      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
      allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)

      visit checkout_state_path(:payment)
    end

    it "selects first source available and customer moves on" do
      expect(find_existing_payment_radio(wallet_source.id)).to be_checked

      click_on "Save and Continue"
      check 'Agree to Terms of Service'
      click_on "Place Order"

      order = Spree::Order.last
      expect(page).to have_current_path(order_path(order))
      expect(page).to have_content("Ending in #{credit_card.last_digits}")
    end

    it "allows user to enter a new source" do
      find_payment_radio(bogus.id).click
      fill_in_credit_card

      click_on "Save and Continue"
      check 'Agree to Terms of Service'
      click_on "Place Order"

      order = Spree::Order.last
      expect(page).to have_current_path(order_path(order))
      expect(page).to have_content('Ending in 1111')
    end
  end

  # regression for https://github.com/spree/spree/issues/2921
  context "goes back from payment to add another item", js: true do
    let!(:bag) { create(:product, name: "RoR Bag") }

    it "transit nicely through checkout steps again" do
      add_mug_to_cart
      checkout_as_guest
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"
      expect(page).to have_current_path(checkout_state_path("payment"))

      visit products_path
      click_link bag.name
      click_button "add-to-cart-button"

      click_on "Checkout"
      # edit an address field
      fill_in "order_bill_address_attributes_name", with: "Ryann"
      click_button 'Save and Continue'

      expect(page).to have_content "package from NY Warehouse"
      click_button 'Save and Continue'

      expect(page).to have_content "Check"
      click_button 'Save and Continue'

      expect(page).to have_content "Put your terms and conditions here"
      check 'Agree to Terms of Service'
      click_button 'Place Order'

      order = Spree::Order.last
      expect(page).to have_current_path(token_order_path(order, order.guest_token))
    end
  end

  context "from payment step customer goes back to cart", js: true do
    before do
      add_mug_to_cart
      checkout_as_guest
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"
      expect(page).to have_current_path(checkout_state_path("payment"))
    end

    context "and updates line item quantity and try to reach payment page" do
      before do
        stock_location.stock_items.update_all(count_on_hand: 5)
        visit cart_path
        within '.cart-item__quantity' do
          fill_in "order_line_items_attributes_0_quantity", with: 3
        end

        click_on "Update"
        expect(page).to have_content("$59.97")
      end

      it "redirects user back to address step" do
        visit checkout_state_path("payment")
        expect(page).to have_current_path(checkout_state_path("address"))
      end

      it "updates shipments properly through step address -> delivery transitions" do
        visit checkout_state_path("payment")
        expect(page).to have_content "Billing Address"
        click_on "Save and Continue"
        expect(page).to have_content "package from NY Warehouse"
        click_on "Save and Continue"
        expect(page).to have_content "Payment Information"

        expect(Spree::InventoryUnit.count).to eq 3
      end
    end

    context "and adds new product to cart and try to reach payment page" do
      let!(:bag) { create(:product, name: "RoR Bag") }

      before do
        visit products_path
        click_link bag.name
        click_button "add-to-cart-button"
        expect(page).to have_content "Shopping Cart"
      end

      it "redirects user back to address step" do
        visit checkout_state_path("payment")
        expect(page).to have_current_path(checkout_state_path("address"))
      end

      it "updates shipments properly through step address -> delivery transitions" do
        visit checkout_state_path("payment")
        expect(page).to have_content "Billing Address"
        click_on "Save and Continue"
        expect(page).to have_content "package from NY Warehouse"
        click_on "Save and Continue"
        expect(page).to have_content "Payment Information"

        expect(Spree::InventoryUnit.count).to eq 2
      end
    end
  end

  context "Coupon promotions", js: true do
    let!(:promotion) { create(:promotion, name: "Huhuhu", code: "huhu") }
    let!(:calculator) { Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: "10") }
    let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(calculator: calculator) }

    before do
      promotion.actions << action

      add_mug_to_cart
      checkout_as_guest

      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"

      click_on "Save and Continue"
      expect(page).to have_current_path(checkout_state_path("payment"))
    end

    it "applies them & refreshes the page on user clicking the Apply Code button" do
      fill_in "order_coupon_code", with: promotion.codes.first.value
      click_on "Apply Code"

      expect(page).to have_content(promotion.name)
      expect(page).to have_content("-$2.00")
    end

    context "with invalid coupon" do
      it "doesnt apply the promotion" do
        fill_in "order_coupon_code", with: 'invalid'
        click_on "Apply Code"

        expect(page).to have_content(I18n.t('spree.coupon_code_not_found'))
      end
    end

    context "doesn't fill in coupon code input" do
      it "advances just fine" do
        click_on "Save and Continue"
        expect(page).to have_current_path(checkout_state_path("confirm"))
      end
    end
  end

  context "order has only payment step", js: true do
    before do
      create(:credit_card_payment_method)
      @old_checkout_flow = Spree::Order.checkout_flow
      Spree::Order.class_eval do
        checkout_flow do
          go_to_state :payment
          go_to_state :confirm
        end
      end

      allow_any_instance_of(Spree::Order).to receive_messages email: "spree@commerce.com"

      add_mug_to_cart
      click_on "Checkout"
    end

    after do
      Spree::Order.checkout_flow(&@old_checkout_flow)
    end

    it "goes right payment step and place order just fine" do
      expect(page).to have_current_path(checkout_state_path('payment'))

      choose "Credit Card"
      fill_in_credit_card
      click_button "Save and Continue"

      expect(current_path).to eq checkout_state_path('confirm')
      check 'Agree to Terms of Service'
      click_button "Place Order"
    end
  end

  context "save my address" do
    before do
      stock_location.stock_items.update_all(count_on_hand: 1)
      add_mug_to_cart
    end

    context 'as a guest' do
      before do
        Spree::Order.last.update_column(:email, "test@example.com")
        click_button "Checkout"
      end

      it 'should not be displayed', js: true do
        expect(page).to_not have_css("[data-hook=save_user_address]")
      end
    end

    context 'as a User' do
      before do
        user = create(:user)
        Spree::Order.last.update_column :user_id, user.id
        allow_any_instance_of(CartsController).to receive_messages(spree_current_user: user)
        allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)
        allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
        click_button "Checkout"
      end

      it 'should be displayed', js: true do
        expect(page).to have_css('#save-user-address')
      end
    end
  end

  context "when order is completed" do
    let!(:user) { create(:user) }
    let!(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:delivery, user: user) }

    before(:each) do
      allow_any_instance_of(CheckoutsController).to receive_messages(current_order: order)
      allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
      allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)
      allow_any_instance_of(CartLineItemsController).to receive_messages(spree_current_user: user)

      visit checkout_state_path(:delivery)
      expect(page).to have_content "package from NY Warehouse"
      click_button 'Save and Continue'

      expect(page).to have_content "Check"
      click_button 'Save and Continue'

      expect(page).to have_content "Put your terms and conditions here"
      check 'Agree to Terms of Service'
      click_button 'Place Order'
    end

    it "displays a thank you message" do
      expect(page).to have_content(I18n.t('spree.thank_you_for_your_order'), normalize_ws: true)
    end

    it "does not display a thank you message on that order future visits" do
      visit order_path(order)
      expect(page).to_not have_content(I18n.t('spree.thank_you_for_your_order'))
    end
  end

  context "with attempted XSS", js: true do
    shared_examples "safe from XSS" do
      let(:user) { create(:user) }

      # We need a country with states required but no states so that we have
      # access to the state_name input
      let!(:canada) { create(:country, name: 'Canada', iso: "CA", states_required: true) }
      before do
        canada.states.destroy_all
        zone.members.create!(zoneable: canada)
      end

      it "displays the entered state name without evaluating" do
        add_mug_to_cart
        visit checkout_state_path(:address)

        # Unlike with the other examples in this spec, calling
        # `checkout_as_guest` in this example causes this example to fail
        # intermittently. Please see
        # https://github.com/solidusio/solidus_starter_frontend/pull/172/files#r683067589
        # for more details.
        within '#existing-customer' do
          fill_in 'Email:', with: user.email
          fill_in 'Password:', with: user.password
          click_button 'Login'
        end

        fill_in_address
        fill_in 'Customer email', with: 'test@example.com'

        state_name_css = "order_bill_address_attributes_state_name"

        select "Canada", from: "order_bill_address_attributes_country_id"
        fill_in state_name_css, with: xss_string
        fill_in "Zip", with: "H0H0H0"

        click_on 'Save and Continue'
        visit checkout_state_path(:address)

        expect(page).to have_field(state_name_css, with: xss_string)
      end
    end

    let(:xss_string) { %(<script>throw("XSS")</script>) }
    include_examples "safe from XSS"

    context "escaped XSS string" do
      let(:xss_string) { '\x27\x3e\x3cscript\x3ethrow(\x27XSS\x27)\x3c/script\x3e' }
      include_examples "safe from XSS"
    end
  end

  context "using credit card" do
    let!(:payment_method) { create(:credit_card_payment_method) }

    # Regression test for https://github.com/solidusio/solidus/issues/1421
    it "works with card number 1", js: true do
      add_mug_to_cart

      checkout_as_guest
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"

      fill_in_credit_card(number: "1")
      click_on "Save and Continue"

      expect(page).to have_current_path("/checkout/confirm")
    end

    it "works with card number 4111111111111111", js: true do
      add_mug_to_cart

      checkout_as_guest
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"

      fill_in_credit_card
      click_on "Save and Continue"

      expect(page).to have_current_path("/checkout/confirm")
    end
  end

  def fill_in_credit_card(number: "4111 1111 1111 1111")
    fill_in "Name on card", with: 'Mary Doe'
    fill_in_with_force "Card Number", with: number
    fill_in_with_force "Expiration", with: "12 / 24"
    fill_in "Card Code", with: "123"
  end

  def fill_in_address
    address = "order_bill_address_attributes"
    fill_in "#{address}_name", with: "Ryan Bigg"
    fill_in "#{address}_address1", with: "143 Swan Street"
    fill_in "#{address}_city", with: "Richmond"
    select "United States of America", from: "#{address}_country_id"
    select "Alabama", from: "#{address}_state_id"
    fill_in "#{address}_zipcode", with: "12345"
    fill_in "#{address}_phone", with: "(555) 555-5555"
  end

  def add_mug_to_cart
    visit products_path
    click_link mug.name
    click_button "add-to-cart-button"
  end
end
