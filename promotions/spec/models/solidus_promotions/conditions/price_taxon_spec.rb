# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::PriceTaxon, type: :model do
  let(:taxon) { create :taxon, name: "first" }
  let(:taxon2) { create :taxon, name: "second" }
  let(:price) { create(:price, variant:) }
  let(:variant) { create(:variant, product:) }
  let(:product) { create(:product, taxons: product_taxons) }
  let(:product_taxons) { [] }
  let(:condition_taxons) { [] }
  let(:preferred_match_policy) { "include" }
  let(:condition) do
    described_class.new(taxons: condition_taxons, preferred_match_policy:)
  end

  it_behaves_like "a taxon condition"

  it { is_expected.to be_updateable }

  describe "#eligible?" do
    let(:taxon) { create :taxon, name: "first" }

    context "with an invalid match policy" do
      let(:preferred_match_policy) { "invalid" }
      let(:condition_taxons) { [taxon] }
      let(:product_taxons) { [taxon] }

      it "raises" do
        expect {
          condition.eligible?(price)
        }.to raise_error('unexpected match policy: "invalid"')
      end
    end

    context "when a product has a taxon of a taxon condition" do
      let(:condition_taxons) { [taxon] }
      let(:product_taxons) { [taxon] }

      it "is eligible" do
        expect(condition).to be_eligible(price)
      end
    end

    context "when a product has a taxon child of a taxon condition" do
      let(:condition_taxons) { [taxon] }
      let(:product_taxons) { [taxon2] }

      before do
        taxon.children << taxon2
      end

      it "is eligible" do
        expect(condition).to be_eligible(price)
      end

      context "with 'exclude' match policy" do
        let(:preferred_match_policy) { "exclude" }

        it "is not eligible" do
          expect(condition).not_to be_eligible(price)
        end
      end
    end

    context "when a product does not have taxon or child taxon of a taxon condition" do
      let(:condition_taxons) { [taxon] }
      let(:product_taxons) { [taxon2] }

      it "is not eligible" do
        expect(condition).not_to be_eligible(price)
      end

      context "with 'exclude' match policy" do
        before do
          condition.update(preferred_match_policy: :exclude)
        end

        it "is eligible" do
          expect(condition).to be_eligible(price)
        end
      end
    end
  end
end
