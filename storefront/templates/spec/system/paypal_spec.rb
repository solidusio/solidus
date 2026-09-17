# frozen_string_literal: true

require "solidus_storefront_spec_helper"

RSpec.describe "Checkout" do
  def js_sdk_script_query
    URI(page.find('script[src*="sdk/js?"]', visible: false)[:src]).query.split('&')
  end

  def js_sdk_script_partner_id
    page.find('script[src*="sdk/js?"]', visible: false)['data-partner-attribution-id']
  end

  describe "paypal payment method" do
    let(:order) { Spree::TestingSupport::OrderWalkthrough.up_to(:payment) }
    let(:paypal_payment_method) { create(:paypal_payment_method) }
    let(:failed_response) { double('response', status_code: 500) } # rubocop:disable RSpec/VerifiedDoubles

    before do
      user = create(:user)
      visit '/'
      click_link 'Login'
      fill_in 'spree_user[email]', with: user.email
      fill_in 'spree_user[password]', with: 'secret'
      click_button 'Login'
      order.user = user
      order.recalculate

      paypal_payment_method
      allow_any_instance_of(CheckoutsController).to receive_messages(
        current_order: order, try_spree_current_user: user
      )
    end

    context "when generating a script tag" do
      it "generates a url with the correct credentials attached" do
        visit '/checkout/payment'
        expect(js_sdk_script_query).to include("client-id=#{paypal_payment_method.preferences[:client_id]}")
      end

      it "generates a partner_id attribute with the correct partner code attached" do
        visit '/checkout/payment'
        expect(js_sdk_script_partner_id).to eq("Solidus_PCP_SP")
      end

      it "generates a URL with the correct currency" do
        allow(order).to receive(:currency).and_return "EUR"
        visit '/checkout/payment'
        expect(js_sdk_script_query).to include("currency=EUR")
      end

      context "when auto-capture is set to true" do
        it "generates a url with intent capture" do
          paypal_payment_method.update(auto_capture: true)
          visit '/checkout/payment'
          expect(js_sdk_script_query).to include("client-id=#{paypal_payment_method.preferences[:client_id]}")
          expect(js_sdk_script_query).to include("intent=capture")
        end
      end
    end

    context "when no payment has been made" do
      it "fails to process" do
        visit '/checkout/payment'
        choose(option: paypal_payment_method.id)
        click_button("Save and Continue")
        expect(page).to have_content("Payments source PayPal order can't be blank")
      end
    end

    context "when a payment has been made" do
      it "proceeds to the next step" do
        visit '/checkout/payment'
        choose(option: paypal_payment_method.id)
        find(:xpath, "//input[@id='payments_source_paypal_order_id']", visible: false).set SecureRandom.hex(8)
        click_button("Save and Continue")
        expect(page).to have_css(".current", text: "Confirm")
      end

      it "records the paypal email address" do
        visit '/checkout/payment'
        choose(option: paypal_payment_method.id)
        find(:xpath, "//input[@id='payments_source_paypal_order_id']", visible: false).set SecureRandom.hex(8)
        find(:xpath, "//input[@id='payments_source_paypal_email']", visible: false).set "fake@email.com"
        click_button("Save and Continue")
        expect(Spree::Payment.last.source.paypal_email).to eq "fake@email.com"
      end

      it "records the paypal funding source" do
        visit '/checkout/payment'
        choose(option: paypal_payment_method.id)
        find(:xpath, "//input[@id='payments_source_paypal_order_id']", visible: false).set SecureRandom.hex(8)
        find(:xpath, "//input[@id='payments_source_paypal_email']", visible: false).set "fake@email.com"
        find(:xpath, "//input[@id='payments_source_paypal_funding_source']", visible: false).set "venmo"
        click_button("Save and Continue")
        expect(Spree::Payment.last.source.paypal_funding_source).to eq "venmo"
      end
    end

    context "when a payment fails" do
      before { allow_any_instance_of(PayPal::PayPalHttpClient).to receive(:execute) { failed_response } }

      it "redirects the user back to the payments page" do
        visit '/checkout/payment'
        choose(option: paypal_payment_method.id)
        find(:xpath, "//input[@id='payments_source_paypal_order_id']", visible: false).set SecureRandom.hex(8)
        click_button("Save and Continue")
        click_button("Place Order")
        expect(page).to have_current_path("/checkout/payment")
        expect(page).to have_content("Your payment was declined")
      end
    end
  end
end
