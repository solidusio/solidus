# frozen_string_literal: true

require 'spec_helper'

describe 'products', type: :feature, caching: true do
  let!(:product) { create(:product) }
  let!(:product2) { create(:product) }
  let!(:taxonomy) { create(:taxonomy) }
  let!(:taxon) { create(:taxon, taxonomy: taxonomy) }

  before do
    product2.update_column(:updated_at, 1.day.ago)
    # warm up the cache
    visit spree.root_path

    clear_cache_events
  end

  it "reads from cache upon a second viewing" do
    visit spree.root_path
    expect(cache_writes.count).to eq(0)
  end

  it "busts the cache when a product is updated" do
    product.update_column(:updated_at, 1.day.from_now)
    visit spree.root_path
    expect(cache_writes.count).to eq(2)
  end

  it "busts the cache when all products are soft-deleted" do
    product.discard
    product2.discard
    visit spree.root_path
    expect(cache_writes.count).to eq(1)
  end

  it "busts the cache when the newest product is soft-deleted" do
    product.discard
    visit spree.root_path
    expect(cache_writes.count).to eq(1)
  end

  it "busts the cache when an older product is soft-deleted" do
    product2.discard
    visit spree.root_path
    expect(cache_writes.count).to eq(1)
  end
end
