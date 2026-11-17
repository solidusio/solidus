# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionCode do
  context "callbacks" do
    subject { promotion_code.save }

    describe "#normalize_code" do
      let(:promotion) { create(:promotion, code:) }

      before { subject }

      context "when no other code with the same value exists" do
        let(:promotion_code) { promotion.codes.first }

        context "with mixed case" do
          let(:code) { "NewCoDe" }

          it "downcases the value before saving" do
            expect(promotion_code.value).to eq("newcode")
          end
        end

        context "with extra spacing" do
          let(:code) { " new code " }

          it "removes surrounding whitespace" do
            expect(promotion_code.value).to eq "new code"
          end
        end
      end

      context "when another code with the same value exists" do
        let(:promotion_code) { promotion.codes.build(value: code) }

        context "with mixed case" do
          let(:code) { "NewCoDe" }

          it "does not save the record and marks it as invalid" do
            expect(promotion_code.valid?).to eq false

            expect(promotion_code.errors.messages[:value]).to contain_exactly(
              "has already been taken"
            )
          end
        end

        context "with extra spacing" do
          let(:code) { " new code " }

          it "does not save the record and marks it as invalid" do
            expect(promotion_code.valid?).to eq false

            expect(promotion_code.errors.messages[:value]).to contain_exactly(
              "has already been taken"
            )
          end
        end
      end
    end
  end

  describe "#usage_limit_exceeded_from_orders?" do
    subject { code.usage_limit_exceeded_from_orders? }

    shared_examples "it should" do
      context "when there is a usage limit" do
        context "and the limit is not exceeded" do
          let(:usage_limit) { 10 }
          it { is_expected.to be_falsy }
        end
        context "and the limit is exceeded" do
          let(:usage_limit) { 1 }
          context "on a different order" do
            before do
              FactoryBot.create(
                :completed_order_with_promotion,
                promotion:
              )
              code.adjustments.update_all(eligible: true)
            end
            it { is_expected.to be_truthy }
          end
          context "on the same order" do
            it { is_expected.to be_falsy }
          end
        end
      end
      context "when there is no usage limit" do
        let(:usage_limit) { nil }
        it { is_expected.to be_falsy }
      end
    end

    let(:code) { promotion.codes.first }

    context "with an order-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :promotion,
          :with_order_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      let(:promotable) do
        FactoryBot.create(
          :completed_order_with_promotion,
          promotion:
        )
      end
      it_behaves_like "it should"
    end

    context "with an item-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :promotion,
          :with_line_item_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      before do
        promotion.actions.first.perform({
          order:,
          promotion:,
          promotion_code: code
        })
      end
      context "when there are multiple line items" do
        let(:order) { FactoryBot.create(:order_with_line_items, line_items_count: 2) }
        describe "the first item" do
          let(:promotable) { order.line_items.first }
          it_behaves_like "it should"
        end
        describe "the second item" do
          let(:promotable) { order.line_items.last }
          it_behaves_like "it should"
        end
      end
      context "when there is a single line item" do
        let(:order) { FactoryBot.create(:order_with_line_items) }
        let(:promotable) { order.line_items.first }
        it_behaves_like "it should"
      end
    end
  end

  describe "#usage_count_from_orders" do
    let(:promotion) do
      FactoryBot.create(
        :promotion,
        :with_order_adjustment,
        code: "discount"
      )
    end
    let(:code) { promotion.codes.first }

    subject { code.usage_count_from_orders }

    context "when the code is applied to a non-complete order" do
      let(:order) { FactoryBot.create(:order_with_line_items) }
      before { promotion.activate(order:, promotion_code: code) }
      it { is_expected.to eq 0 }
    end
    context "when the code is applied to a complete order" do
      let!(:order) do
        FactoryBot.create(
          :completed_order_with_promotion,
          promotion:
        )
      end
      context "and the promo is eligible" do
        it { is_expected.to eq 1 }
      end
      context "and the promo is ineligible" do
        before { order.adjustments.promotion.update_all(eligible: false) }
        it { is_expected.to eq 0 }
      end
      context "and the order is canceled" do
        before { order.cancel! }
        it { is_expected.to eq 0 }
        it { expect(order.state).to eq "canceled" }
      end
    end
  end

  describe "#usage_count" do
    let(:promotion) { create(:promotion, :with_order_adjustment, code: "discount", per_code_usage_limit:) }
    let(:per_code_usage_limit) { 5 }
    let(:code) { promotion.codes.first }
    let!(:order) { create(:completed_order_with_promotion, promotion:) }

    context "without a usage limit" do
      let(:per_code_usage_limit) { nil }

      it "counts the completed orders" do
        expect(code.usage_count).to eq(1)
      end
    end

    it "counts the claimed uses" do
      2.times { code.claim_usage }
      expect(code.reload.usage_count).to eq(2)
    end

    it "doesn't count the excluded completed orders' claims" do
      2.times { code.claim_usage }
      expect(code.reload.usage_count(excluded_orders: [order])).to eq(1)
    end

    it "doesn't count the claim of an excluded order that is completing" do
      completing_order = create(:order_with_line_items)
      completing_order.promotion_usage_claims = [code]
      stale_code = Spree::PromotionCode.find(code.id)
      code.claim_usage

      expect(stale_code.usage_count(excluded_orders: [completing_order])).to eq(0)
    end
  end

  describe "#usage_limit_exceeded?" do
    let(:promotion) { create(:promotion, :with_order_adjustment, code: "discount", per_code_usage_limit: 1) }
    let(:code) { promotion.codes.first }
    let!(:order) { create(:completed_order_with_promotion, promotion:) }

    it "is exceeded when the uses have been claimed, regardless of completed orders" do
      expect(code.usage_limit_exceeded?).to be(false)
      code.claim_usage
      expect(code.reload.usage_limit_exceeded?).to be(true)
    end

    it "isn't exceeded for the order holding the last claim" do
      code.claim_usage
      expect(code.reload.usage_limit_exceeded?(excluded_orders: [order])).to be(false)
    end
  end

  it "cannot create promotion code on apply automatically promotion" do
    promotion = create(:promotion, apply_automatically: true)
    expect {
      create(:promotion_code, promotion:)
    }.to raise_error ActiveRecord::RecordInvalid, "Validation failed: Could not create promotion code on promotion that apply automatically"
  end
end
