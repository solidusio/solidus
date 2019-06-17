# frozen_string_literal: true

require 'spec_helper'

describe "Switching currencies in backend", type: :feature do
  before do
    create(:store)
    create(:base_product, name: "RoR Mug")
  end

  # Regression test for https://github.com/spree/spree/issues/2340
  it "does not cause current_order to become nil", inaccessible: true do
    visit spree.root_path
    click_link "RoR Mug"
    click_button "Add To Cart"
    # Now that we have an order...
    stub_spree_preferences(currency: "AUD")
    visit spree.root_path
  end
end
