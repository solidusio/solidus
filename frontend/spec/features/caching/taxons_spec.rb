require 'spec_helper'

describe 'taxons', :type => :feature, :caching => true do
  let!(:taxonomy) { create(:taxonomy) }
  let!(:taxon) { create(:taxon, :taxonomy => taxonomy) }

  before do
    # warm up the cache
    visit solidus.root_path
    assert_written_to_cache("views/en/solidus/taxonomies/#{taxonomy.id}")
    assert_written_to_cache("views/en/taxons/#{taxon.updated_at.utc.to_i}")

    clear_cache_events
  end

  it "busts the cache when max_level_in_taxons_menu conf changes" do
    Solidus::Config[:max_level_in_taxons_menu] = 5
    visit solidus.root_path
    assert_written_to_cache("views/en/solidus/taxonomies/#{taxonomy.id}")
    expect(cache_writes.count).to eq(1)
  end
end
