# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Conditions::LineItemTaxon, type: :model do
  let(:taxon) { create :taxon, name: "first" }
  let(:taxon2) { create :taxon, name: "second" }
  let(:order) { create :order_with_line_items }
  let(:product) { order.products.first }

  let(:condition) do
    described_class.create!(promotion: create(:friendly_promotion))
  end

  describe "#eligible?" do
    let(:line_item) { order.line_items.first! }
    let(:order) { create :order_with_line_items }
    let(:taxon) { create :taxon, name: "first" }

    context "with an invalid match policy" do
      before do
        condition.preferred_match_policy = "invalid"
        condition.save!(validate: false)
        line_item.product.taxons << taxon
        condition.taxons << taxon
      end

      it "raises" do
        expect {
          condition.eligible?(line_item)
        }.to raise_error('unexpected match policy: "invalid"')
      end
    end

    context "when a product has a taxon of a taxon condition" do
      before do
        product.taxons << taxon
        condition.taxons << taxon
        condition.save!
      end

      it "is eligible" do
        expect(condition).to be_eligible(line_item)
      end
    end

    context "when a product has a taxon child of a taxon condition" do
      before do
        taxon.children << taxon2
        product.taxons << taxon2
        condition.taxons << taxon
        condition.save!
      end

      it "is eligible" do
        expect(condition).to be_eligible(line_item)
      end

      context "with 'exclude' match policy" do
        before do
          condition.update(preferred_match_policy: :exclude)
        end

        it "is not eligible" do
          expect(condition).not_to be_eligible(line_item)
        end
      end
    end

    context "when a product does not have taxon or child taxon of a taxon condition" do
      before do
        product.taxons << taxon2
        condition.taxons << taxon
        condition.save!
      end

      it "is not eligible" do
        expect(condition).not_to be_eligible(line_item)
      end

      context "with 'exclude' match policy" do
        before do
          condition.update(preferred_match_policy: :exclude)
        end

        it "is not eligible" do
          expect(condition).to be_eligible(line_item)
        end
      end
    end
  end
end
