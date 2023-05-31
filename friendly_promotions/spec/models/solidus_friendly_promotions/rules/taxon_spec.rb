# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::Rules::Taxon, type: :model do
  let(:taxon) { create :taxon, name: "first" }
  let(:taxon2) { create :taxon, name: "second" }
  let(:order) { create :order_with_line_items }
  let(:product) { order.products.first }

  let(:rule) do
    SolidusFriendlyPromotions::Rules::Taxon.create!(promotion: create(:promotion))
  end

  context "#eligible?(order)" do
    context "with any match policy" do
      before do
        rule.update!(preferred_match_policy: "any")
      end

      it "is eligible if order does have any prefered taxon" do
        product.taxons << taxon
        rule.taxons << taxon
        expect(rule).to be_eligible(order)
      end

      context "when order does not have any prefered taxon" do
        before { rule.taxons << taxon2 }
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "You need to add a product from an applicable category before applying this coupon code."
        end
        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :no_matching_taxons
        end
      end

      context "when a product has a taxon child of a taxon rule" do
        before do
          taxon.children << taxon2
          product.taxons << taxon2
          rule.taxons << taxon
        end

        it { expect(rule).to be_eligible(order) }
      end
    end

    context "with all match policy" do
      before do
        rule.update!(preferred_match_policy: "all")
      end

      it "is eligible order has all prefered taxons" do
        product.taxons << taxon2
        order.products.last.taxons << taxon

        rule.taxons = [taxon, taxon2]

        expect(rule).to be_eligible(order)
      end

      context "when order does not have all prefered taxons" do
        before { rule.taxons << taxon }
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "You need to add a product from all applicable categories before applying this coupon code."
        end
        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code])
            .to eq :missing_taxon
        end
      end

      context "when a product has a taxon child of a taxon rule" do
        let(:taxon3) { create :taxon }

        before do
          taxon.children << taxon2
          taxon.save!
          taxon.reload

          product.taxons = [taxon2, taxon3]
          rule.taxons = [taxon, taxon3]
        end

        it { expect(rule).to be_eligible(order) }
      end
    end

    context "with none match policy" do
      before do
        rule.preferred_match_policy = "none"
      end

      context "none of the order's products are in listed taxon" do
        before { rule.taxons << taxon2 }
        it { expect(rule).to be_eligible(order) }
      end

      context "one of the order's products is in a listed taxon" do
        before do
          order.products.first.taxons << taxon
          rule.taxons << taxon
        end
        it "should not be eligible" do
          expect(rule).not_to be_eligible(order)
        end
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first)
            .to eq "Your cart contains a product from an excluded category that prevents this coupon code from being applied."
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
        order.products.first.taxons << taxon
        rule.taxons << taxon
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
end
