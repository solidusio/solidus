# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Coupon code promotions', type: :system, js: true do
  include_context 'featured products'
  include  SolidusStarterFrontend::System::CheckoutHelpers

  let!(:store) { create(:store) }
  let!(:zone) { create(:zone) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:payment_method) { create(:check_payment_method) }
  let!(:product) { create(:product_in_stock, name: "Solidus mug set", price: 20) }
  let!(:address) { create(:address) }

  context "visitor makes checkout" do
    def create_basic_coupon_promotion(code)
      promotion = create(
        :promotion,
        name:       code.titleize,
        code:       code,
        starts_at:  1.day.ago,
        expires_at: 1.day.from_now
      )

      calculator = Spree::Calculator::FlatRate.new
      calculator.preferred_amount = 10

      action = Spree::Promotion::Actions::CreateItemAdjustments.new
      action.calculator = calculator
      action.promotion = promotion
      action.save

      promotion.reload # so that promotion.actions is available
    end

    let!(:promotion) { create_basic_coupon_promotion("onetwo") }

    context "on the payment page" do
      context "as guest without registration" do
        before do
          visit products_path
          click_link "Solidus mug set"
          click_button "add-to-cart-button"
          checkout_as_guest
          fill_addresses_fields_with(address)

          # To shipping method screen
          click_button "Save and Continue"
          # To payment screen
          click_button "Save and Continue"
        end

        it "informs about an invalid coupon code" do
          fill_in "order_coupon_code", with: "coupon_codes_rule_man"
          click_button "Apply Code"
          expect(page).to have_content(I18n.t('spree.coupon_code_not_found'))
        end

        it "can enter an invalid coupon code, then a real one" do
          fill_in "order_coupon_code", with: "coupon_codes_rule_man"
          click_button "Apply Code"
          expect(page).to have_content(I18n.t('spree.coupon_code_not_found'))
          fill_in "order_coupon_code", with: "onetwo"
          click_button "Apply Code"
          expect(page).to have_content("Promotion (Onetwo) -$10.00", normalize_ws: true)
        end

        context "with a promotion" do
          it "applies a promotion to an order" do
            fill_in "order_coupon_code", with: "onetwo"
            click_button "Apply Code"
            expect(page).to have_content("Promotion (Onetwo) -$10.00", normalize_ws: true)
          end
        end
      end

      context 'as logged user' do
        let!(:user) { create(:user, bill_address: create(:address), ship_address: create(:address)) }

        before do
          allow_any_instance_of(CheckoutsController).to receive_messages(spree_current_user: user)
          allow_any_instance_of(OrdersController).to receive_messages(spree_current_user: user)
          allow_any_instance_of(CouponCodesController).to receive_messages(spree_current_user: user)
          allow_any_instance_of(CartsController).to receive_messages(spree_current_user: user)
          allow_any_instance_of(CartLineItemsController).to receive_messages(spree_current_user: user)
        end

        context 'with saved credit card' do
          let(:bogus) { create(:credit_card_payment_method, name: "Bogus Card") }
          let!(:credit_card) do
            create(:credit_card, user_id: user.id, payment_method: bogus, gateway_customer_profile_id: "BGS-WEFWF")
          end
          let!(:wallet_source) { user.wallet.add(credit_card) }

          before do
            visit products_path
            click_link "Solidus mug set"
            click_button "add-to-cart-button"
            # To Cart
            click_button "Checkout"
            # To shipping method screen, address is auto-populated
            # with user's saved addresses
            click_button "Save and Continue"
            # To payment screen
            click_button "Save and Continue"
          end

          it "shows wallet payments on coupon code errors" do
            fill_in "order_coupon_code", with: "coupon_codes_rule_man"
            click_button "Apply Code"

            expect(page).to have_content("The coupon code you entered doesn't exist. Please try again.")
            expect(page).to have_content("Payment Information")
            expect(page).to have_content("Bogus Card")
          end
        end
      end
    end

    # CheckoutsController
    context "on the cart page" do
      before do
        visit products_path
        click_link "Solidus mug set"
        click_button "add-to-cart-button"
      end

      it "can enter a coupon code and receives success notification" do
        fill_in "coupon_code", with: "onetwo"
        click_button "Apply Code"
        expect(page).to have_content(I18n.t('spree.coupon_code_applied'))
      end

      it "can enter a promotion code with both upper and lower case letters" do
        fill_in "coupon_code", with: "ONETwO"
        click_button "Apply Code"
        expect(page).to have_content(I18n.t('spree.coupon_code_applied'))
      end

      it "informs the user about a coupon code which has exceeded its usage" do
        expect_any_instance_of(Spree::Promotion).to receive(:usage_limit_exceeded?).and_return(true)

        fill_in "coupon_code", with: "onetwo"
        click_button "Apply Code"
        expect(page).to have_content(I18n.t('spree.coupon_code_max_usage'))
      end

      context "informs the user if the coupon code is not eligible" do
        before do
          rule = Spree::Promotion::Rules::ItemTotal.new
          rule.promotion = promotion
          rule.preferred_amount = 100
          rule.save
        end

        specify do
          visit cart_path

          fill_in "coupon_code", with: "onetwo"
          click_button "Apply Code"
          expect(page).to have_content(I18n.t(:item_total_less_than_or_equal, scope: [:spree, :eligibility_errors, :messages], amount: "$100.00"))
        end
      end

      it "informs the user if the coupon is expired" do
        promotion.expires_at = Date.today.beginning_of_week
        promotion.starts_at = Date.today.beginning_of_week.advance(day: 3)
        promotion.save!
        fill_in "coupon_code", with: "onetwo"
        click_button "Apply Code"
        expect(page).to have_content(I18n.t('spree.coupon_code_expired'))
      end

      context "calculates the correct amount of money saved with flat percent promotions" do
        before do
          calculator = Spree::Calculator::FlatPercentItemTotal.new
          calculator.preferred_flat_percent = 20
          promotion.actions.first.calculator = calculator
          promotion.save

          create(:product_in_stock, name: "Solidus cap", price: 10)
        end

        specify do
          visit products_path
          click_link "Solidus cap"
          click_button "add-to-cart-button"

          visit cart_path
          fill_in "coupon_code", with: "onetwo"
          click_button "Apply Code"

          fill_in "order_line_items_attributes_0_quantity", with: 2
          fill_in "order_line_items_attributes_1_quantity", with: 2
          click_button "Update"

          within '#cart_adjustments' do
            # 20% of $40 = 8
            # 20% of $20 = 4
            # Therefore: promotion discount amount is $12.
            expect(page).to have_content("Promotion (Onetwo) -$12.00", normalize_ws: true)
          end

          within '.cart-footer__total' do
            expect(page).to have_content("$48.00")
          end
        end
      end

      context "calculates the correct amount of money saved with flat 100% promotions on the whole order" do
        before do
          calculator = Spree::Calculator::FlatPercentItemTotal.new
          calculator.preferred_flat_percent = 100

          promotion.promotion_actions.first.discard

          Spree::Promotion::Actions::CreateAdjustment.create!(
            calculator: calculator,
            promotion: promotion
          )

          create(:product_in_stock, name: "Solidus cap", price: 10)
        end

        specify do
          visit products_path
          click_link "Solidus cap"
          click_button "add-to-cart-button"

          visit cart_path

          within '.cart-footer__total' do
            expect(page).to have_content("$30.00")
          end

          fill_in "coupon_code", with: "onetwo"
          click_button "Apply Code"

          within '#cart_adjustments' do
            expect(page).to have_content("Promotion (Onetwo) -$30.00", normalize_ws: true)
          end

          within '.cart-footer__total' do
            expect(page).to have_content("$0.00")
          end

          fill_in "order_line_items_attributes_0_quantity", with: 2
          fill_in "order_line_items_attributes_1_quantity", with: 2
          click_button "Update"

          within '#cart_adjustments' do
            expect(page).to have_content("Promotion (Onetwo) -$60.00", normalize_ws: true)
          end

          within '.cart-footer__total' do
            expect(page).to have_content("$0.00")
          end
        end
      end
    end
  end
end
