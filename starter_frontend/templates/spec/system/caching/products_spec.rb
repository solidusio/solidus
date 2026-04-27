# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'products', type: :system, caching: true do
  let!(:taxon) { create(:taxon, taxonomy: create(:taxonomy)) }
  let!(:product) { create(:product, taxons: [taxon]) }
  let!(:product2) { create(:product, taxons: [taxon]) }

  before do
    # warm up the cache
    visit products_path

    clear_cache_events
  end

  it "reads from cache upon a second viewing" do
    visit products_path
    expect(cache_writes.count).to eq(0)
  end

  it "busts the cache when a product is updated" do
    product.update(updated_at: 1.day.from_now)
    visit products_path

    # Cache rewrites:
    # - 1 x products grid updated item
    # - 3 x categories in navigation
    expect(cache_writes.count).to eq(4)
  end

  it "busts the cache when all products are soft-deleted" do
    product.discard
    product2.discard
    visit products_path

    # Cache rewrites:
    # - 3 x categories in navigation
    expect(cache_writes.count).to eq(3)
  end

  it "busts the cache when the newest product is soft-deleted" do
    product.discard
    visit products_path

    # Cache rewrites:
    # - 3 x categories in navigation
    expect(cache_writes.count).to eq(3)
  end

  it "busts the cache when an older product is soft-deleted" do
    product2.discard
    visit products_path

    # Cache rewrites:
    # - 3 x categories in navigation
    expect(cache_writes.count).to eq(3)
  end
end
