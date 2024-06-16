# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionCode do
  let(:promotion) { create(:friendly_promotion) }
  subject { create(:friendly_promotion_code, promotion: promotion) }

  it { is_expected.to belong_to(:promotion) }
  it { is_expected.to have_many(:order_promotions).class_name("SolidusFriendlyPromotions::OrderPromotion").dependent(:destroy) }

  context "callbacks" do
    subject { promotion_code.save }

    describe "#normalize_code" do
      let(:promotion) { create(:friendly_promotion, code: code) }

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

  describe "#usage_limit_exceeded?" do
    subject { code.usage_limit_exceeded? }

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
                :completed_order_with_friendly_promotion,
                promotion: promotion
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
          :friendly_promotion,
          :with_order_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      let(:promotable) do
        FactoryBot.create(
          :completed_order_with_friendly_promotion,
          promotion: promotion
        )
      end

      it_behaves_like "it should"
    end

    context "with an item-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :friendly_promotion,
          :with_line_item_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end

      before do
        order.recalculate
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

  describe "#usage_count" do
    subject { code.usage_count }

    let(:promotion) do
      FactoryBot.create(
        :friendly_promotion,
        :with_order_adjustment,
        code: "discount"
      )
    end
    let(:code) { promotion.codes.first }

    context "when the code is applied to a non-complete order" do
      let(:order) { FactoryBot.create(:order_with_line_items) }

      before do
        order.friendly_order_promotions.create(
          promotion: promotion,
          promotion_code: code
        )
        order.recalculate
      end

      it { is_expected.to eq 0 }
    end

    context "when the code is applied to a complete order" do
      let!(:order) do
        FactoryBot.create(
          :completed_order_with_friendly_promotion,
          promotion: promotion
        )
      end

      context "and the promo is eligible" do
        it { is_expected.to eq 1 }
      end

      context "and the promo is ineligible" do
        before { order.all_adjustments.update_all(eligible: false) }

        it { is_expected.to eq 0 }
      end

      context "and the order is canceled" do
        before { order.cancel! }

        it { is_expected.to eq 0 }
        it { expect(order.state).to eq "canceled" }
      end
    end
  end

  describe "completing multiple orders with the same code", slow: true do
    let(:promotion) do
      FactoryBot.create(
        :friendly_promotion,
        :with_order_adjustment,
        code: "discount",
        per_code_usage_limit: 1,
        weighted_order_adjustment_amount: 10
      )
    end
    let(:code) { promotion.codes.first }

    let(:order) do
      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order: order)
      end
    end

    let(:promo_adjustment) { order.all_adjustments.friendly_promotion.first }

    before do
      order.friendly_order_promotions.create!(
        order: order,
        promotion: promotion,
        promotion_code: described_class.find_by(value: "discount")
      )
      order.recalculate
      order.next! until order.can_complete?

      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order: order)
        order.friendly_order_promotions.create!(
          order: order,
          promotion: promotion,
          promotion_code: described_class.find_by(value: "discount")
        )
        order.recalculate
        order.next! until order.can_complete?
        order.complete!
      end
    end

    it "makes the adjustment disappear" do
      expect {
        order.complete
      }.to change { order.all_adjustments.friendly_promotion }.to([])
    end

    it "adjusts the promo_total" do
      expect {
        order.complete
      }.to change(order, :promo_total).by(10)
    end

    it "increases the total to remove the promo" do
      expect {
        order.complete
      }.to change(order, :total).from(30).to(40)
    end

    it "resets the state of the order" do
      expect {
        order.complete
      }.to change { order.reload.state }.from("confirm").to("address")
    end
  end

  it "cannot create promotion code on apply automatically promotion" do
    promotion = create(:friendly_promotion, apply_automatically: true)
    expect {
      create(:friendly_promotion_code, promotion: promotion)
    }.to raise_error ActiveRecord::RecordInvalid,
      "Validation failed: Could not create promotion code on promotion that apply automatically"
  end

  describe "#destroy" do
    subject { promotion_code.destroy }

    let(:promotion_code) { create(:friendly_promotion_code) }
    let(:order) { create(:order_with_line_items) }

    before do
      order.friendly_order_promotions.create(promotion: promotion_code.promotion, promotion_code: promotion_code)
    end

    it "destroys the order_promotion" do
      expect { subject }.to change { SolidusFriendlyPromotions::OrderPromotion.count }.by(-1)
    end
  end
end
