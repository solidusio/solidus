# frozen_string_literal: true

require "rails_helper"

RSpec.describe "countries seed" do
  subject(:seed) { load Spree::Core::Engine.root.join("db/default/spree/countries.rb") }

  it "requires states only for the configured countries that have subregions" do
    stub_spree_preferences(countries_that_require_states: %w[US DE HK])

    seed

    expect(Spree::Country.where(states_required: true).pluck(:iso)).to contain_exactly("US", "DE")
  end
end
