# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::TaxonsHelper, type: :helper do
  let(:currency) { 'USD' }
  let(:pricing_options) do
    Spree::Config.pricing_options_class.new(currency: currency)
  end
  before do
    without_partial_double_verification do
      allow(helper).to receive(:current_pricing_options) { pricing_options }
    end
  end

  describe "#taxon_preview" do
    let!(:taxon) { create(:taxon) }
    let!(:child_taxon) { create(:taxon, parent: taxon) }
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }
    let!(:product_3) { create(:product) }

    before do
      taxon.products << product_1
      taxon.products << product_2
      child_taxon.products << product_3
      taxon.reload
    end

    # Regression test for https://github.com/spree/spree/issues/4382
    it "returns products" do
      expect(helper.taxon_preview(taxon)).to eql([product_1, product_2, product_3])
    end

    context "with different currency" do
      let(:currency) { 'CAD' }

      it "returns no products" do
        expect(helper.taxon_preview(taxon)).to be_empty
      end
    end
  end
end
