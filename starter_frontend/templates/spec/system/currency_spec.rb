# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Switching currencies in backend', type: :system do
  include_context 'featured products'

  before do
    create(:store)
    create(:base_product, name: "Solidus mug set")
  end

  # Regression test for https://github.com/spree/spree/issues/2340
  it "does not cause current_order to become nil" do
    visit products_path
    click_link "Solidus mug set"
    click_button "Add To Cart"
    # Now that we have an order...
    stub_spree_preferences(currency: "AUD")
    visit root_path
  end
end
