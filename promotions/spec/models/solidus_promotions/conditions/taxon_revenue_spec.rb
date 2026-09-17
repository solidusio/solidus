# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::TaxonRevenue do
  subject(:condition) { described_class.new(preferred_amount:, taxons: [matching_taxon]) }
  let(:preferred_amount) { 30 }

  let(:matching_product) { build(:product, taxons: [matching_taxon]) }
  let(:non_matching_product) { build(:product, taxons: [other_taxon]) }
  let(:matching_variant) { build(:variant, product: matching_product) }
  let(:non_matching_variant) { build(:variant, product: non_matching_product) }

  let(:matching_taxon) { create(:taxon) }
  let(:other_taxon) { create(:taxon) }

  let(:matching_item) { build(:line_item, variant: matching_variant, price: 30) }
  let(:non_matching_item) { build(:line_item, variant: non_matching_variant, price: 50) }
  let(:order) { build(:order, line_items: [matching_item, non_matching_item]) }

  describe "preferences" do
    subject(:condition) { described_class.new }
    it "defaults preferred_operator to 'gte'" do
      expect(condition.preferred_operator).to eq("gte")
    end

    it "defaults preferred_amount to 0" do
      expect(condition.preferred_amount).to eq(0)
    end

    it "accepts 'gt' as a valid operator" do
      condition.preferred_operator = "gt"
      expect(condition.preferred_operator).to eq("gt")
    end

    it "defaults preferred_match_policy to 'include'" do
      expect(condition.preferred_match_policy).to eq("include")
    end

    it "accepts 'exclude' as a valid match policy" do
      condition.preferred_match_policy = "exclude"
      expect(condition.preferred_match_policy).to eq("exclude")
    end

    it "is invalid with an unrecognized match policy" do
      condition.preferred_match_policy = "some_other_policy"
      expect(condition).not_to be_valid
      expect(condition.errors[:preferred_match_policy]).to be_present
    end
  end

  describe "taxons association" do
    it "can have multiple taxons" do
      condition.taxons << other_taxon
      expect(condition.taxons).to include(matching_taxon, other_taxon)
    end
  end

  describe ".operator_options" do
    subject(:operator_options) { described_class.operator_options }

    it {
      is_expected.to contain_exactly(
        ["greater than or equal to", "gte"],
        ["greater than", "gt"],
        ["less than", "lt"],
        ["less than or equal to", "lte"]
      )
    }
  end

  describe ".match_policy_options" do
    subject(:match_policy_options) { described_class.match_policy_options }

    it {
      is_expected.to contain_exactly(
        ["Revenue from selected taxons", "include"],
        ["Revenue excluding selected taxons", "exclude"]
      )
    }
  end

  describe "#order_eligible?" do
    context "with operator 'gte' (default)" do
      context "when the taxon revenue equals the threshold" do
        it "is eligible" do
          # matching_item.discounted_amount == 30, non_matching_item is ignored
          expect(condition).to be_order_eligible(order)
        end
      end

      context "when the taxon revenue exceeds the threshold" do
        let(:matching_item) { build(:line_item, variant: matching_variant, price: 50) }

        it "is eligible" do
          expect(condition).to be_order_eligible(order)
        end
      end

      context "when the taxon revenue is below the threshold" do
        let(:matching_item) { build(:line_item, variant: matching_variant, price: 10) }

        it "is not eligible" do
          expect(condition).not_to be_order_eligible(order)
        end
      end
    end

    context "with operator 'gt' (strictly greater than)" do
      before do
        condition.preferred_operator = "gt"
      end

      context "when the taxon revenue equals the threshold exactly" do
        it "is not eligible" do
          # matching_item.discounted_amount == 30
          expect(condition).not_to be_order_eligible(order)
        end
      end

      context "when the taxon revenue exceeds the threshold" do
        let(:matching_item) { build(:line_item, variant: matching_variant, price: 31) }

        it "is eligible" do
          expect(condition).to be_order_eligible(order)
        end
      end
    end

    context "when no line items belong to the configured taxons" do
      let(:order) { build(:order, line_items: [non_matching_item]) }
      let(:preferred_amount) { 10 }

      it "is not eligible because the taxon revenue is zero" do
        expect(condition).not_to be_order_eligible(order)
      end
    end

    context "when the order has no line items" do
      let(:order) { build_stubbed(:order, line_items: []) }
      it "is not eligible" do
        expect(condition).not_to be_order_eligible(order)
      end

      context "when the preferred amount is zero" do
        let(:preferred_amount) { 0 }

        it { is_expected.to be_order_eligible(order) }
      end
    end

    context "when multiple taxons are configured" do
      let(:preferred_amount) { 50 }
      let(:other_matching_item) { build(:line_item, price: 25, product: non_matching_product) }
      let(:order) { build_stubbed(:order, line_items: [matching_item, other_matching_item, non_matching_item]) }

      before do
        condition.taxons << other_taxon
      end
      it "sums discounted amounts from all matching taxons" do
        # 30 (taxon) + 25 (other_taxon) = 55 >= 50
        expect(condition).to be_order_eligible(order)
      end
    end

    context "when a line item belongs to multiple taxons" do
      let(:multi_taxon_item) { build(:line_item, price: 30, product: multi_taxon_product) }
      let(:multi_taxon_product) { build(:product, taxons: [matching_taxon, other_taxon]) }
      let(:order) { build_stubbed(:order, line_items: [multi_taxon_item]) }
      let(:preferred_amount) { 35 }

      it "counts the item once (no double-counting)" do
        expect(condition).not_to be_order_eligible(order)
      end

      context "and all are eligible" do
        before do
          condition.taxons << other_taxon
        end

        it "still counts the item only once" do
          # 40, not 80
          expect(condition).not_to be_order_eligible(order)
        end
      end
    end

    context "when the discounted_amount reflects applied promotions" do
      before { condition.preferred_amount = 20 }

      let(:order) { build_stubbed(:order, line_items: [matching_item]) }

      before do
        allow(matching_item).to receive(:discounted_amount).and_return(15)
      end
      it "uses the discounted amount, not the original price" do
        expect(condition).not_to be_order_eligible(order)
      end
    end

    context "when no taxons are configured on the condition" do
      subject(:condition) { described_class.new(preferred_amount: 1) }

      it "does not count any line items and is not eligible above zero" do
        expect(condition).not_to be_order_eligible(order)
      end
    end

    context "when preferred_match_policy is 'exclude'" do
      before { condition.preferred_match_policy = "exclude" }

      context "when the non-excluded-taxon revenue equals the threshold" do
        let(:preferred_amount) { 50 }

        it "is eligible" do
          # matching_item (in matching_taxon) is excluded from the sum;
          # only non_matching_item (50) counts, and 50 >= 50
          expect(condition).to be_order_eligible(order)
        end
      end

      context "when the non-excluded-taxon revenue exceeds the threshold" do
        let(:preferred_amount) { 40 }

        it "is eligible" do
          expect(condition).to be_order_eligible(order)
        end
      end

      context "when the non-excluded-taxon revenue is below the threshold" do
        let(:preferred_amount) { 60 }

        it "is not eligible" do
          # only non_matching_item (50) counts, 50 < 60
          expect(condition).not_to be_order_eligible(order)
        end
      end

      it "does not count revenue from line items in the excluded taxon" do
        # If the excluded item were counted, total would be 80 (30 + 50).
        # With it excluded, only 50 counts, so a threshold of 51 is not met.
        condition.preferred_amount = 51
        expect(condition).not_to be_order_eligible(order)
      end

      context "when all line items belong to the excluded taxon" do
        let(:order) { build_stubbed(:order, line_items: [matching_item]) }
        let(:preferred_amount) { 1 }

        it "is not eligible because the non-excluded revenue is zero" do
          expect(condition).not_to be_order_eligible(order)
        end

        context "when the preferred amount is zero" do
          let(:preferred_amount) { 0 }

          it { is_expected.to be_order_eligible(order) }
        end
      end

      context "when multiple taxons are excluded" do
        let(:other_excluded_item) { build(:line_item, price: 25, product: non_matching_product) }
        let(:third_taxon) { create(:taxon) }
        let(:third_product) { build(:product, taxons: [third_taxon]) }
        let(:remaining_item) { build(:line_item, price: 15, product: third_product) }
        let(:order) { build_stubbed(:order, line_items: [matching_item, other_excluded_item, remaining_item]) }
        let(:preferred_amount) { 15 }

        before do
          condition.taxons << other_taxon
        end

        it "only counts revenue from line items outside every excluded taxon" do
          # matching_item (matching_taxon) and other_excluded_item (other_taxon) are excluded;
          # only remaining_item (15) counts, and 15 >= 15
          expect(condition).to be_order_eligible(order)
        end
      end

      context "when a line item belongs to both an excluded and a non-excluded taxon" do
        let(:multi_taxon_item) { build(:line_item, price: 30, product: multi_taxon_product) }
        let(:multi_taxon_product) { build(:product, taxons: [matching_taxon, other_taxon]) }
        let(:order) { build_stubbed(:order, line_items: [multi_taxon_item]) }
        let(:preferred_amount) { 1 }

        it "is excluded, since it belongs to the excluded taxon" do
          expect(condition).not_to be_order_eligible(order)
        end
      end

      context "when no taxons are configured on the condition" do
        subject(:condition) { described_class.new(preferred_amount:, preferred_match_policy: "exclude") }
        let(:preferred_amount) { 79 }

        it "counts all line items, since none belong to an excluded taxon" do
          # 30 + 50 = 80 >= 79
          expect(condition).to be_order_eligible(order)
        end
      end
    end
  end
end
