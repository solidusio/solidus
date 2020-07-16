# frozen_string_literal: true

require 'spec_helper'

describe "Checkout", type: :feature, inaccessible: true do
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

      it "should default checkbox to checked", inaccessible: true do
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
        click_button "Checkout"
      end

      specify do
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
        click_button "Checkout"

        fill_in "order_email", with: "test@example.com"
        fill_in_address

        click_button "Save and Continue"
        expect(page).not_to have_content("undefined method `promotion'")
        click_button "Save and Continue"
        expect(page).to have_content("Shipping total: $10.00")
      end
    end

    # Regression test for https://github.com/spree/spree/issues/4306
    context "free shipping" do
      before do
        add_mug_to_cart
        click_button "Checkout"
      end

      it "should not show 'Free Shipping' when there are no shipments" do
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
        allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
        allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
        allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)

        add_mug_to_cart
        click_button "Checkout"
        # We need an order reload here to get newly associated addresses.
        # Then we go back to address where we are supposed to be redirected.
        order.reload
        visit spree.checkout_state_path(:address)
      end

      context "when user has default addresses saved" do
        let(:saved_bill_address) { create(:address, firstname: 'Bill') }
        let(:saved_ship_address) { create(:address, firstname: 'Steve') }

        it "shows the saved addresses" do
          within("#billing") do
            expect(find_field('First Name').value).to eq 'Bill'
          end

          within("#shipping") do
            expect(find_field('First Name').value).to eq 'Steve'
          end
        end
      end

      context "when user does not have default addresses saved" do
        let(:saved_bill_address) { nil }
        let(:saved_ship_address) { nil }

        it 'shows an empty address' do
          within("#billing") do
            expect(find_field('First Name').value).to be_nil
          end

          within("#shipping") do
            expect(find_field('First Name').value).to be_nil
          end
        end
      end
    end

    context "when user is not logged in" do
      context "and proceeds with guest checkout" do
        it 'shows empty addresses' do
          add_mug_to_cart
          click_button "Checkout"

          within("#billing") do
            expect(find_field('First Name').value).to be_nil
          end

          within("#shipping") do
            expect(find_field('First Name').value).to be_nil
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
          allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
          allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)

          # Simulate redirect back to address after login
          visit spree.checkout_state_path(:address)
        end

        context "when does not have saved addresses" do
          let(:saved_bill_address) { nil }
          let(:saved_ship_address) { nil }

          it 'shows empty addresses' do
            within("#billing") do
              expect(find_field('First Name').value).to be_nil
            end

            within("#shipping") do
              expect(find_field('First Name').value).to be_nil
            end
          end
        end

        # Regression test for https://github.com/solidusio/solidus/issues/1811
        context "when does have saved addresses" do
          let(:saved_bill_address) { create(:address, firstname: 'Bill') }
          let(:saved_ship_address) { create(:address, firstname: 'Steve') }

          it 'shows empty addresses' do
            within("#billing") do
              expect(find_field('First Name').value).to eq 'Bill'
            end

            within("#shipping") do
              expect(find_field('First Name').value).to eq 'Steve'
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

      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
    end

    it "does not allow successful order submission" do
      visit spree.checkout_path
      order.payments.first.update state: :void
      click_button 'Place Order'
      expect(page).to have_current_path spree.checkout_state_path(:payment)
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

      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
    end

    it "redirects to payment page", inaccessible: true do
      visit spree.checkout_state_path(:delivery)
      click_button "Save and Continue"
      choose "Credit Card"
      fill_in "Card Number", with: '123'
      fill_in "card_expiry", with: '04 / 20'
      fill_in "Card Code", with: '123'
      click_button "Save and Continue"
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
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(skip_state_validation?: true)
    end

    it "prevents double clicking the payment button on checkout", js: true do
      visit spree.checkout_state_path(:payment)

      # prevent form submit to verify button is disabled
      page.execute_script("$('#checkout_form_payment').submit(function(){return false;})")

      expect(page).not_to have_selector('input.button[disabled]')
      click_button "Save and Continue"
      expect(page).to have_selector('input.button[disabled]')
    end

    it "prevents double clicking the confirm button on checkout", js: true do
      order.payments << create(:payment)
      visit spree.checkout_state_path(:confirm)

      # prevent form submit to verify button is disabled
      page.execute_script("$('#checkout_form_confirm').submit(function(){return false;})")

      expect(page).not_to have_selector('input.button[disabled]')
      click_button "Place Order"
      expect(page).to have_selector('input.button[disabled]')
    end
  end

  context "when several payment methods are available" do
    let(:credit_cart_payment) { create(:credit_card_payment_method) }
    let(:check_payment) { create(:check_payment_method) }

    after do
      Capybara.ignore_hidden_elements = true
    end

    before do
      Capybara.ignore_hidden_elements = false
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery)
      allow(order).to receive_messages(available_payment_methods: [check_payment, credit_cart_payment])
      order.user = create(:user)
      order.recalculate

      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: order.user)

      visit spree.checkout_state_path(:payment)
    end

    it "the first payment method should be selected", js: true do
      payment_method_css = "#order_payments_attributes__payment_method_id_"
      expect(find("#{payment_method_css}#{check_payment.id}")).to be_checked
      expect(find("#{payment_method_css}#{credit_cart_payment.id}")).not_to be_checked
    end

    it "the fields for the other payment methods should be hidden", js: true do
      payment_method_css = "#payment_method_"
      expect(find("#{payment_method_css}#{check_payment.id}")).to be_visible
      expect(find("#{payment_method_css}#{credit_cart_payment.id}")).not_to be_visible
    end
  end

  context "user has payment sources", js: true do
    before { Spree::PaymentMethod.all.each(&:really_destroy!) }
    let!(:bogus) { create(:credit_card_payment_method) }
    let(:user) { create(:user) }

    let!(:credit_card) do
      create(:credit_card, user_id: user.id, payment_method: bogus, gateway_customer_profile_id: "BGS-WEFWF")
    end

    before do
      user.wallet.add(credit_card)
      order = Spree::TestingSupport::OrderWalkthrough.up_to(:delivery)

      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
      allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)

      visit spree.checkout_state_path(:payment)
    end

    it "selects first source available and customer moves on" do
      expect(find("#use_existing_card_yes")).to be_checked

      click_on "Save and Continue"
      click_on "Place Order"
      expect(page).to have_current_path(spree.order_path(Spree::Order.last))
      expect(page).to have_current_path(spree.order_path(Spree::Order.last))
      expect(page).to have_content("Ending in #{credit_card.last_digits}")
    end

    it "allows user to enter a new source" do
      choose "use_existing_card_no"
      fill_in_credit_card

      click_on "Save and Continue"
      click_on "Place Order"
      expect(page).to have_current_path(spree.order_path(Spree::Order.last))
      expect(page).to have_content('Ending in 1111')
    end

    it "allows user to save a billing address associated to the credit card" do
      choose "use_existing_card_no"
      fill_in_credit_card

      click_on "Save and Continue"
      expect(Spree::CreditCard.last.address).to be_present
    end
  end

  # regression for https://github.com/spree/spree/issues/2921
  context "goes back from payment to add another item", js: true do
    let!(:store) { FactoryBot.create(:store) }
    let!(:bag) { create(:product, name: "RoR Bag") }

    it "transit nicely through checkout steps again" do
      add_mug_to_cart
      click_on "Checkout"
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"
      expect(page).to have_current_path(spree.checkout_state_path("payment"))

      visit spree.root_path
      click_link bag.name
      click_button "add-to-cart-button"

      click_on "Checkout"
      # edit an address field
      fill_in "order_bill_address_attributes_firstname", with: "Ryann"
      click_on "Save and Continue"
      click_on "Save and Continue"
      click_on "Save and Continue"
      click_on "Place Order"

      expect(page).to have_current_path(spree.order_path(Spree::Order.last))
    end
  end

  context "from payment step customer goes back to cart", js: true do
    before do
      add_mug_to_cart
      click_on "Checkout"
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"
      expect(page).to have_current_path(spree.checkout_state_path("payment"))
    end

    context "and updates line item quantity and try to reach payment page" do
      before do
        visit spree.cart_path
        within ".cart-item-quantity" do
          fill_in first("input")["name"], with: 3
        end

        click_on "Update"
      end

      it "redirects user back to address step" do
        visit spree.checkout_state_path("payment")
        expect(page).to have_current_path(spree.checkout_state_path("address"))
      end

      it "updates shipments properly through step address -> delivery transitions" do
        visit spree.checkout_state_path("payment")
        click_on "Save and Continue"
        click_on "Save and Continue"

        expect(Spree::InventoryUnit.count).to eq 3
      end
    end

    context "and adds new product to cart and try to reach payment page" do
      let!(:bag) { create(:product, name: "RoR Bag") }

      before do
        visit spree.root_path
        click_link bag.name
        click_button "add-to-cart-button"
      end

      it "redirects user back to address step" do
        visit spree.checkout_state_path("payment")
        expect(page).to have_current_path(spree.checkout_state_path("address"))
      end

      it "updates shipments properly through step address -> delivery transitions" do
        visit spree.checkout_state_path("payment")
        click_on "Save and Continue"
        click_on "Save and Continue"

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
      click_on "Checkout"

      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"

      click_on "Save and Continue"
      expect(page).to have_current_path(spree.checkout_state_path("payment"))
    end

    it "applies them & refreshes the page on user clicking the Apply Code button" do
      fill_in "Coupon Code", with: promotion.codes.first.value
      click_on "Apply Code"

      expect(page).to have_content(promotion.name)
      expect(page).to have_content("-$2.00")
    end

    context "with invalid coupon" do
      it "doesnt apply the promotion" do
        fill_in "Coupon Code", with: 'invalid'
        click_on "Apply Code"

        expect(page).to have_content(I18n.t('spree.coupon_code_not_found'))
      end
    end

    context "doesn't fill in coupon code input" do
      it "advances just fine" do
        click_on "Save and Continue"
        expect(page).to have_current_path(spree.checkout_state_path("confirm"))
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
      expect(page).to have_current_path(spree.checkout_state_path('payment'))

      choose "Credit Card"
      fill_in_credit_card
      click_button "Save and Continue"

      expect(current_path).to eq spree.checkout_state_path('confirm')
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

      it 'should not be displayed' do
        expect(page).to_not have_css("[data-hook=save_user_address]")
      end
    end

    context 'as a User' do
      before do
        user = create(:user)
        Spree::Order.last.update_column :user_id, user.id
        allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)
        allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
        click_button "Checkout"
      end

      it 'should be displayed' do
        expect(page).to have_css("[data-hook=save_user_address]")
      end
    end
  end

  context "when order is completed" do
    let!(:user) { create(:user) }
    let!(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:delivery) }

    before(:each) do
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(current_order: order)
      allow_any_instance_of(Spree::CheckoutController).to receive_messages(try_spree_current_user: user)
      allow_any_instance_of(Spree::OrdersController).to receive_messages(try_spree_current_user: user)

      visit spree.checkout_state_path(:delivery)
      click_button "Save and Continue"
      click_button "Save and Continue"
      click_button "Place Order"
    end

    it "displays a thank you message" do
      expect(page).to have_content(I18n.t('spree.thank_you_for_your_order'), normalize_ws: true)
    end

    it "does not display a thank you message on that order future visits" do
      visit spree.order_path(order)
      expect(page).to_not have_content(I18n.t('spree.thank_you_for_your_order'))
    end
  end

  context "with attempted XSS", js: true do
    shared_examples "safe from XSS" do
      # We need a country with states required but no states so that we have
      # access to the state_name input
      let!(:canada) { create(:country, name: 'Canada', iso: "CA", states_required: true) }
      before do
        canada.states.destroy_all
        zone.members.create!(zoneable: canada)
      end

      it "displays the entered state name without evaluating" do
        add_mug_to_cart
        visit spree.checkout_state_path(:address)
        fill_in_address

        state_name_css = "order_bill_address_attributes_state_name"

        select "Canada", from: "order_bill_address_attributes_country_id"
        fill_in 'Customer E-Mail', with: 'test@example.com'
        fill_in state_name_css, with: xss_string
        fill_in "Zip", with: "H0H0H0"

        click_on 'Save and Continue'
        visit spree.checkout_state_path(:address)

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

      click_on "Checkout"
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

      click_on "Checkout"
      fill_in "order_email", with: "test@example.com"
      fill_in_address
      click_on "Save and Continue"
      click_on "Save and Continue"

      fill_in_credit_card
      click_on "Save and Continue"

      expect(page).to have_current_path("/checkout/confirm")
    end
  end

  # Regression test for: https://github.com/solidusio/solidus/issues/2998
  context 'when two shipping categories are available' do
    let!(:first_category) { create(:shipping_category) }
    let!(:second_category) { create(:shipping_category) }

    let!(:first_shipping_method) do
      create(:shipping_method,
             shipping_categories: [first_category],
             stores: [store])
    end

    let!(:second_shipping_method) do
      create(:shipping_method,
             shipping_categories: [second_category],
             stores: [store])
    end

    context 'assigned to two different products' do
      let!(:first_product) do
        create(:product,
               name: 'First product',
               shipping_category: first_category)
      end

      let!(:second_product) do
        create(:product,
               name: 'Second product',
               shipping_category: second_category)
      end

      before do
        stock_location.stock_items.update_all(count_on_hand: 10)
      end

      it 'transitions successfully to the delivery step', js: true do
        visit spree.product_path(first_product)
        click_button 'add-to-cart-button'
        visit spree.product_path(second_product)
        click_button 'add-to-cart-button'

        click_button 'Checkout'

        fill_in_address
        fill_in 'order_email', with: 'test@example.com'
        click_button 'Save and Continue'

        expect(Spree::Order.last.state).to eq('delivery')
      end
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
    fill_in "#{address}_firstname", with: "Ryan"
    fill_in "#{address}_lastname", with: "Bigg"
    fill_in "#{address}_address1", with: "143 Swan Street"
    fill_in "#{address}_city", with: "Richmond"
    select "United States of America", from: "#{address}_country_id"
    select "Alabama", from: "#{address}_state_id"
    fill_in "#{address}_zipcode", with: "12345"
    fill_in "#{address}_phone", with: "(555) 555-5555"
  end

  def add_mug_to_cart
    visit spree.root_path
    click_link mug.name
    click_button "add-to-cart-button"
  end
end
