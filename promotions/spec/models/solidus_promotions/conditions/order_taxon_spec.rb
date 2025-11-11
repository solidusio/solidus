# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::OrderTaxon, type: :model do
  let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
  let(:promotion_benefit) { promotion.benefits.first }
  let(:condition) do
    described_class.create!(benefit: promotion_benefit)
  end
  let(:product) { order.products.first }
  let(:order) { create :order_with_line_items }
  let(:taxon_one) { create :taxon, name: "first" }
  let(:taxon_two) { create :taxon, name: "second" }

  it_behaves_like "a taxon condition"

  it { is_expected.to be_updateable }

  describe "#eligible?(order)" do
    context "with any match policy" do
      before do
        condition.update!(preferred_match_policy: "any")
      end

      it "is eligible if order does have any prefered taxon" do
        product.taxons << taxon_one
        condition.taxons << taxon_one
        expect(condition).to be_eligible(order)
      end

      context "when order does not have any prefered taxon" do
        before { condition.taxons << taxon_two }

        it { expect(condition).not_to be_eligible(order) }

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first).to eq(
            "You need to add a product from an applicable category before applying this coupon code."
          )
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :no_matching_taxons
        end
      end

      context "when a product has a taxon child of a taxon condition" do
        before do
          taxon_one.children << taxon_two
          product.taxons << taxon_two
          condition.taxons << taxon_one
        end

        it { expect(condition).to be_eligible(order) }
      end
    end

    context "with all match policy" do
      before do
        condition.update!(preferred_match_policy: "all")
      end

      it "is eligible order has all prefered taxons" do
        product.taxons << taxon_two
        order.products.last.taxons << taxon_one

        condition.taxons = [taxon_one, taxon_two]

        expect(condition).to be_eligible(order)
      end

      context "when order does not have all prefered taxons" do
        before { condition.taxons << taxon_one }

        it { expect(condition).not_to be_eligible(order) }

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first).to eq(
            "You need to add a product from all applicable categories before applying this coupon code."
          )
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :missing_taxon
        end
      end

      context "when a product has a taxon child of a taxon condition" do
        let(:taxon_three) { create :taxon }

        before do
          taxon_one.children << taxon_two
          taxon_one.save!
          taxon_one.reload

          product.taxons = [taxon_two, taxon_three]
          condition.taxons = [taxon_one, taxon_three]
        end

        it { expect(condition).to be_eligible(order) }
      end
    end

    context "with none match policy" do
      before do
        condition.preferred_match_policy = "none"
      end

      context "none of the order's products are in listed taxon" do
        before { condition.taxons << taxon_two }

        it { expect(condition).to be_eligible(order) }
      end

      context "one of the order's products is in a listed taxon" do
        before do
          order.products.first.taxons << taxon_one
          condition.taxons << taxon_one
        end

        it "is not eligible" do
          expect(condition).not_to be_eligible(order)
        end

        it "sets an error message" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.full_messages.first).to eq(
            "Your cart contains a product from an excluded category that prevents this coupon code from being applied."
          )
        end

        it "sets an error code" do
          condition.eligible?(order)
          expect(condition.eligibility_errors.details[:base].first[:error_code])
            .to eq :has_excluded_taxon
        end
      end
    end
  end

  describe "#to_partial_path" do
    subject { condition.to_partial_path }

    it { is_expected.to eq("solidus_promotions/admin/condition_fields/taxon") }
  end
end
