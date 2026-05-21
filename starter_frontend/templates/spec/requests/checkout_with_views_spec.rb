# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

# This spec is useful for when we just want to make sure a view is rendering correctly
# Walking through the entire checkout process is rather tedious, don't you think?
RSpec.describe 'Checkout view rendering', type: :request, with_signed_in_user: true do
  let(:token) { 'some_token' }
  let(:user) { create(:user) }
  # Regression test for https://github.com/spree/spree/issues/3246
  context "when using GBP" do
    before do
      stub_spree_preferences(currency: "GBP")
    end

    context "when order is in delivery" do
      before do
        # Using a let block won't acknowledge the currency setting
        # Therefore we just do it like this...
        order = Spree::TestingSupport::OrderWalkthrough.up_to(:address)
        order.update(user: user)
      end

      it "displays rate cost in correct currency" do
        get checkout_path
        html = Nokogiri::HTML(response.body)
        expect(html.css('.shipping-methods__rate').text.strip).to include("£10")
      end
    end
  end
end
