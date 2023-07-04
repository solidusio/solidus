# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::LineItemTaxon, type: :model do
  let(:taxon) { create :taxon, name: "first" }
  let(:taxon2) { create :taxon, name: "second" }
  let(:order) { create :order_with_line_items }
  let(:product) { order.products.first }

  let(:rule) do
    described_class.create!(promotion: create(:friendly_promotion))
  end

  describe "#eligible?" do
    let(:line_item) { order.line_items.first! }
    let(:order) { create :order_with_line_items }
    let(:taxon) { create :taxon, name: "first" }

    context "with an invalid match policy" do
      before do
        rule.preferred_match_policy = "invalid"
        rule.save!(validate: false)
        line_item.product.taxons << taxon
        rule.taxons << taxon
      end

      it "raises" do
        expect {
          rule.eligible?(line_item)
        }.to raise_error('unexpected match policy: "invalid"')
      end
    end

    context "when a product has a taxon of a taxon rule" do
      before do
        product.taxons << taxon
        rule.taxons << taxon
        rule.save!
      end

      it "is eligible" do
        expect(rule).to be_eligible(line_item)
      end
    end

    context "when a product has a taxon child of a taxon rule" do
      before do
        taxon.children << taxon2
        product.taxons << taxon2
        rule.taxons << taxon
        rule.save!
      end

      it "is eligible" do
        expect(rule).to be_eligible(line_item)
      end

      context "with 'exclude' match policy" do
        before do
          rule.update(preferred_match_policy: :exclude)
        end

        it "is not eligible" do
          expect(rule).not_to be_eligible(line_item)
        end
      end
    end

    context "when a product does not have taxon or child taxon of a taxon rule" do
      before do
        product.taxons << taxon2
        rule.taxons << taxon
        rule.save!
      end

      it "is not eligible" do
        expect(rule).not_to be_eligible(line_item)
      end

      context "with 'exclude' match policy" do
        before do
          rule.update(preferred_match_policy: :exclude)
        end

        it "is not eligible" do
          expect(rule).to be_eligible(line_item)
        end
      end
    end
  end
end
