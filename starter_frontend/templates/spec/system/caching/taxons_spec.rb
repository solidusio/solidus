# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'taxons', type: :system, caching: true do
  let!(:taxonomy) { create(:taxonomy) }
  let!(:taxon) { create(:taxon, taxonomy: taxonomy) }

  before do
    # Warm up the cache
    visit products_path

    clear_cache_events
  end

  it "busts the cache when a taxon changes" do
    taxon.touch(:updated_at)

    visit products_path
    # Cache rewrites:
    # - 2 x categories component
    # - 1 x categories in navigation
    expect(cache_writes.count).to eq(3)
  end

  it "busts the cache when max_level_in_taxons_menu conf changes" do
    stub_spree_preferences(max_level_in_taxons_menu: 5)
    visit products_path

    # Cache rewrites:
    # - 2 x categories component
    expect(cache_writes.count).to eq(2)
  end
end
