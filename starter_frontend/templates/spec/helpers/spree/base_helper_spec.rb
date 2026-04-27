# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::BaseHelper, type: :helper do
  # Regression test for https://github.com/spree/spree/issues/2759
  it "nested_taxons_path works with a Taxon object" do
    taxonomy = create(:taxonomy, name: 'smartphone')
    taxon = create(:taxon, taxonomy: taxonomy, name: "iphone")

    expect(nested_taxons_path(taxon)).to eq("/t/smartphone/iphone")
  end
end
