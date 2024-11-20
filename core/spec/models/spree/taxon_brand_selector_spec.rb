# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::TaxonBrandSelector, type: :model do
  let(:taxonomy) { create(:taxonomy, name: "Brands") }
  let(:taxon) { create(:taxon, taxonomy: taxonomy, name: "Brand A") }
  let(:product) { create(:product, taxons: [taxon]) }

  subject { described_class.new(product) }

  describe "#call" do
    context "when the product has a taxon under the 'Brands' taxonomy" do
      it "returns the first taxon under 'Brands'" do
        expect(subject.call).to eq(taxon)
      end
    end
  end
end
