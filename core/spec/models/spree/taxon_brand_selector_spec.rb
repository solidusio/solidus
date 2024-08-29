# frozen_string_literal: true

require "rails_helper"

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

    context "when the product has multiple taxons under the 'Brands' taxonomy" do
      let(:taxon_b) { create(:taxon, taxonomy: taxonomy, name: "Brand B") }
      before { product.taxons << taxon_b }

      it "returns the first taxon under 'Brands'" do
        expect(subject.call).to eq(taxon)
      end
    end

    context "when the product does not have a taxon under the 'Brands' taxonomy" do
      let(:other_taxonomy) { create(:taxonomy, name: "Categories") }
      let(:other_taxon) { create(:taxon, taxonomy: other_taxonomy, name: "Category A") }
      let(:product) { create(:product, taxons: [other_taxon]) }

      it "returns nil" do
        expect(subject.call).to be_nil
      end
    end

    context "when the product has no taxons" do
      let(:product) { create(:product) }

      it "returns nil" do
        expect(subject.call).to be_nil
      end
    end
  end
end
