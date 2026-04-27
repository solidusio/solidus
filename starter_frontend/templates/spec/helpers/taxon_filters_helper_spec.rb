# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe TaxonFiltersHelper, type: :helper do
  let(:taxon) { nil }
  subject { applicable_filters_for(taxon) }

  it "returns the price/brand filters" do
    expect(subject.map { |y| y[:name] }).to eq ['Brands', 'Price Range']
  end
end
