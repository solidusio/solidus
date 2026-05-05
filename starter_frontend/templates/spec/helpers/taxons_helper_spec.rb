# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe TaxonsHelper, type: :helper do
  describe '#taxon_seo_url' do
    let(:taxonomy) { create(:taxonomy, name: 'Categories') }
    let(:taxon) { create(:taxon, name: 'Clothing', taxonomy: taxonomy) }

    it 'is the nested taxons path for the taxon' do
      expect(taxon_seo_url(taxon)).to eq("/t/categories/clothing")
    end
  end
end
