# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::Taxon, type: :model do
  let(:rule) do
    described_class.create!(promotion: create(:friendly_promotion))
  end
  let(:product) { order.products.first }
  let(:order) { create :order_with_line_items }
  let(:taxon_one) { create :taxon, name: "first" }
  let(:taxon_two) { create :taxon, name: "second" }

  it { is_expected.to have_many(:taxons) }

  describe "taxon_ids_string=" do
    subject { rule.assign_attributes("taxon_ids_string" => taxon_two.id.to_s) }

    let!(:promotion) { create(:friendly_promotion) }

    let(:rule) { promotion.rules.build(type: described_class.to_s) }

    it "creates a valid rule with a taxon" do
      subject
      expect(rule).to be_valid
      rule.save!
      expect(rule.reload.taxons).to include(taxon_two)
    end
  end

  describe "#eligible?(order)" do
    context "with any match policy" do
      before do
        rule.update!(preferred_match_policy: "any")
      end

      it "is eligible if order does have any prefered taxon" do
        product.taxons << taxon_one
        rule.taxons << taxon_one
        expect(rule).to be_eligible(order)
      end

      context "when order does not have any prefered taxon" do
        before { rule.taxons << taxon_two }

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).to eq(
            "You need to add a product from an applicable category before applying this coupon code."
          )
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :no_matching_taxons
        end
      end

      context "when a product has a taxon child of a taxon rule" do
        before do
          taxon_one.children << taxon_two
          product.taxons << taxon_two
          rule.taxons << taxon_one
        end

        it { expect(rule).to be_eligible(order) }
      end
    end

    context "with all match policy" do
      before do
        rule.update!(preferred_match_policy: "all")
      end

      it "is eligible order has all prefered taxons" do
        product.taxons << taxon_two
        order.products.last.taxons << taxon_one

        rule.taxons = [taxon_one, taxon_two]

        expect(rule).to be_eligible(order)
      end

      context "when order does not have all prefered taxons" do
        before { rule.taxons << taxon_one }

        it { expect(rule).not_to be_eligible(order) }

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).to eq(
            "You need to add a product from all applicable categories before applying this coupon code."
          )
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :missing_taxon
        end
      end

      context "when a product has a taxon child of a taxon rule" do
        let(:taxon_three) { create :taxon }

        before do
          taxon_one.children << taxon_two
          taxon_one.save!
          taxon_one.reload

          product.taxons = [taxon_two, taxon_three]
          rule.taxons = [taxon_one, taxon_three]
        end

        it { expect(rule).to be_eligible(order) }
      end
    end

    context "with none match policy" do
      before do
        rule.preferred_match_policy = "none"
      end

      context "none of the order's products are in listed taxon" do
        before { rule.taxons << taxon_two }

        it { expect(rule).to be_eligible(order) }
      end

      context "one of the order's products is in a listed taxon" do
        before do
          order.products.first.taxons << taxon_one
          rule.taxons << taxon_one
        end

        it "is not eligible" do
          expect(rule).not_to be_eligible(order)
        end

        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).to eq(
            "Your cart contains a product from an excluded category that prevents this coupon code from being applied."
          )
        end

        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :has_excluded_taxon
        end
      end
    end

    context "with an invalid match policy" do
      before do
        order.products.first.taxons << taxon_one
        rule.taxons << taxon_one
        rule.preferred_match_policy = "invalid"
        rule.save!(validate: false)
      end

      it "raises" do
        expect {
          rule.eligible?(order)
        }.to raise_error('unexpected match policy: "invalid"')
      end
    end
  end

  describe "#eligible?(line_item)" do
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
        taxon.children << taxon_two
        product.taxons << taxon_two
        rule.taxons << taxon
        rule.save!
      end

      it "is eligible" do
        expect(rule).to be_eligible(line_item)
      end
    end

    context "when a product does not have taxon or child taxon of a taxon rule" do
      before do
        product.taxons << taxon_two
        rule.taxons << taxon
        rule.save!
      end

      it "is not eligible" do
        expect(rule).not_to be_eligible(line_item)
      end
    end
  end
end
