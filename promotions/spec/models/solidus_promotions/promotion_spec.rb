# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Promotion, type: :model do
  let(:promotion) { described_class.new }

  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to respond_to(:customer_label) }
  it { is_expected.to have_many :conditions }
  it { is_expected.to have_many(:order_promotions).dependent(:destroy) }
  it { is_expected.to have_many(:code_batches).dependent(:destroy) }

  describe "lane" do
    it { is_expected.to respond_to(:lane) }

    it "is default be default" do
      expect(subject.lane).to eq("default")
    end
  end

  describe "#destroy" do
    let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, apply_automatically: true) }

    subject { promotion.destroy! }

    it "destroys the promotion and deletes the benefit" do
      expect { subject }.to change { SolidusPromotions::Promotion.count }.by(-1)
      expect(SolidusPromotions::Benefit.count).to be_zero
    end

    context "when the promotion has been applied to a complete order" do
      let(:order) { create(:order_ready_to_complete) }

      before do
        order.recalculate
        order.complete!
      end

      it "raises an error" do
        expect { subject }.to raise_exception(ActiveRecord::RecordNotDestroyed)
      end
    end

    context "when the promotion has been added to an incomplete order" do
      let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
      let(:order) { create(:order) }

      before do
        order.solidus_promotions << promotion
      end

      it "destroys the connection" do
        expect { subject }.to change(SolidusPromotions::OrderPromotion, :count).by(-1)
      end
    end
  end

  describe "#discard" do
    let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, apply_automatically: true) }

    subject { promotion.discard! }

    it "discards the promotion and keeps the benefit" do
      expect { subject }.to change { SolidusPromotions::Promotion.count }.by(-1)
    end

    it "keeps the benefit" do
      expect { subject }.not_to change(SolidusPromotions::Benefit, :count)
    end

    context "when the promotion has been applied to a complete order" do
      let(:order) { create(:order_ready_to_complete) }

      before do
        order.recalculate
        order.complete!
      end

      it "does not complain" do
        expect { subject }.not_to raise_exception
      end
    end

    context "when the promotion has been added to an incomplete order" do
      let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
      let(:order) { create(:order) }

      before do
        order.solidus_promotions << promotion
      end

      it "destroys the connection" do
        expect { subject }.to change(SolidusPromotions::OrderPromotion, :count).by(-1)
      end
    end

    context "when the promotion has been added to a complete order" do
      let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
      let(:order) { create(:order_ready_to_ship) }

      before do
        order.solidus_promotions << promotion
      end

      it "keeps the connection" do
        expect { subject }.not_to change(SolidusPromotions::OrderPromotion, :count)
      end
    end
  end

  describe ".ordered_lanes" do
    subject { described_class.ordered_lanes }

    it { is_expected.to eq({ "pre" => 0, "default" => 1, "post" => 2 }) }
  end

  describe "validations" do
    subject(:promotion) { build(:solidus_promotion) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:customer_label) }
    it { is_expected.to validate_numericality_of(:usage_limit).is_greater_than(0) }
  end

  describe ".advertised" do
    let(:promotion) { create(:solidus_promotion) }
    let(:advertised_promotion) { create(:solidus_promotion, advertise: true) }

    it "only shows advertised promotions" do
      advertised = described_class.advertised
      expect(advertised).to include(advertised_promotion)
      expect(advertised).not_to include(promotion)
    end
  end

  describe ".coupons" do
    subject { described_class.coupons }

    let(:promotion_code) { create(:solidus_promotion_code) }
    let!(:promotion_with_code) { promotion_code.promotion }
    let!(:another_promotion_code) { create(:solidus_promotion_code, promotion: promotion_with_code) }
    let!(:promotion_without_code) { create(:solidus_promotion) }

    it "returns only distinct promotions with a code associated" do
      expect(subject).to eq [promotion_with_code]
    end
  end

  describe ".active" do
    subject { described_class.active }

    let(:promotion) { create(:solidus_promotion, starts_at: Date.yesterday, name: "name1") }

    before { promotion }

    it "doesn't return promotion without benefits" do
      expect(subject).to be_empty
    end

    context "when promotion has an benefit" do
      let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, starts_at: Date.yesterday, name: "name1") }

      it "returns promotion with benefit" do
        expect(subject).to match [promotion]
      end
    end

    context "when called with a time that is not current" do
      subject { described_class.active(4.days.ago) }

      let(:promotion) do
        create(
          :solidus_promotion,
          :with_adjustable_benefit,
          starts_at: 5.days.ago,
          expires_at: 3.days.ago,
          name: "name1"
        )
      end

      it "returns promotion that was active then" do
        expect(subject).to match [promotion]
      end
    end
  end

  describe ".has_benefits" do
    subject { described_class.has_benefits }

    let(:promotion) { create(:solidus_promotion, starts_at: Date.yesterday, name: "name1") }

    before { promotion }

    it "doesn't return promotion without benefits" do
      expect(subject).to be_empty
    end

    context "when promotion has two benefits" do
      let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, starts_at: Date.yesterday, name: "name1") }

      before do
        promotion.benefits << SolidusPromotions::Benefits::AdjustShipment.new(calculator: SolidusPromotions::Calculators::Percent.new)
      end

      it "returns distinct promotion" do
        expect(subject).to match [promotion]
      end
    end
  end

  describe "#apply_automatically" do
    subject { create(:solidus_promotion) }

    it "defaults to false" do
      expect(subject.apply_automatically).to eq(false)
    end

    context "when set to true" do
      before { subject.apply_automatically = true }

      it "remains valid" do
        expect(subject).to be_valid
      end

      it "invalidates the promotion when it has a path" do
        subject.path = "foo"
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:apply_automatically)
      end
    end

    context "when the promotion has a code" do
      before do
        subject.codes.new(value: "foo")
      end

      it "cannot be changed to true" do
        expect { subject.apply_automatically = true }.to change { subject.valid? }.from(true).to(false)
        expect(subject.errors.full_messages).to include("Apply automatically cannot be set to true when promotion code is present")
      end
    end
  end

  describe "#usage_limit_exceeded?" do
    subject { promotion.usage_limit_exceeded? }

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
                :completed_order_with_solidus_promotion,
                promotion: promotion
              )
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

    context "with an item-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :solidus_promotion,
          :with_line_item_adjustment,
          code: "discount",
          usage_limit: usage_limit
        )
      end

      before do
        order.solidus_order_promotions.create(
          promotion_code: promotion.codes.first,
          promotion: promotion
        )
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
    subject { promotion.usage_count }

    let(:promotion) do
      FactoryBot.create(
        :solidus_promotion,
        :with_line_item_adjustment,
        code: "discount"
      )
    end

    context "when the code is applied to a non-complete order" do
      let(:order) { FactoryBot.create(:order_with_line_items) }

      before do
        order.solidus_order_promotions.create(
          promotion_code: promotion.codes.first,
          promotion: promotion
        )
        order.recalculate
      end

      it { is_expected.to eq 0 }
    end

    context "when the code is applied to a complete order" do
      let!(:order) do
        FactoryBot.create(
          :completed_order_with_solidus_promotion,
          promotion: promotion
        )
      end

      context "and the promo is eligible" do
        it { is_expected.to eq 1 }
      end

      context "and the promo is ineligible" do
        before do
          promotion.benefits.first.conditions << SolidusPromotions::Conditions::NthOrder.new(preferred_nth_order: 2)
          order.recalculate
        end
        it { is_expected.to eq 0 }
      end

      context "and the order is canceled" do
        before { order.cancel! }

        it { is_expected.to eq 0 }
        it { expect(order.state).to eq "canceled" }
      end
    end
  end

  describe "#inactive" do
    let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }

    it "is not expired" do
      expect(promotion).not_to be_inactive
    end

    it "is inactive if it hasn't started yet" do
      promotion.starts_at = Time.current + 1.day
      expect(promotion).to be_inactive
    end

    it "is inactive if it has already ended" do
      promotion.expires_at = Time.current - 1.day
      expect(promotion).to be_inactive
    end

    it "is not inactive if it has started already" do
      promotion.starts_at = Time.current - 1.day
      expect(promotion).not_to be_inactive
    end

    it "is not inactive if it has not ended yet" do
      promotion.expires_at = Time.current + 1.day
      expect(promotion).not_to be_inactive
    end

    it "is not inactive if current time is within starts_at and expires_at range" do
      promotion.starts_at = Time.current - 1.day
      promotion.expires_at = Time.current + 1.day
      expect(promotion).not_to be_inactive
    end
  end

  describe "#not_started?" do
    subject { promotion.not_started? }

    let(:promotion) { described_class.new(starts_at: starts_at) }

    context "no starts_at date" do
      let(:starts_at) { nil }

      it { is_expected.to be_falsey }
    end

    context "when starts_at date is in the past" do
      let(:starts_at) { Time.current - 1.day }

      it { is_expected.to be_falsey }
    end

    context "when starts_at date is not already reached" do
      let(:starts_at) { Time.current + 1.day }

      it { is_expected.to be_truthy }
    end
  end

  describe "#started?" do
    subject { promotion.started? }

    let(:promotion) { described_class.new(starts_at: starts_at) }

    context "when no starts_at date" do
      let(:starts_at) { nil }

      it { is_expected.to be_truthy }
    end

    context "when starts_at date is in the past" do
      let(:starts_at) { Time.current - 1.day }

      it { is_expected.to be_truthy }
    end

    context "when starts_at date is not already reached" do
      let(:starts_at) { Time.current + 1.day }

      it { is_expected.to be_falsey }
    end
  end

  describe "#expired?" do
    subject { promotion.expired? }

    let(:promotion) { described_class.new(expires_at: expires_at) }

    context "when no expires_at date" do
      let(:expires_at) { nil }

      it { is_expected.to be_falsey }
    end

    context "when expires_at date is not already reached" do
      let(:expires_at) { Time.current + 1.day }

      it { is_expected.to be_falsey }
    end

    context "when expires_at date is in the past" do
      let(:expires_at) { Time.current - 1.day }

      it { is_expected.to be_truthy }
    end
  end

  describe "#not_expired?" do
    subject { promotion.not_expired? }

    let(:promotion) { described_class.new(expires_at: expires_at) }

    context "when no expired_at date" do
      let(:expires_at) { nil }

      it { is_expected.to be_truthy }
    end

    context "when expires_at date is not already reached" do
      let(:expires_at) { Time.current + 1.day }

      it { is_expected.to be_truthy }
    end

    context "when expires_at date is in the past" do
      let(:expires_at) { Time.current - 1.day }

      it { is_expected.to be_falsey }
    end
  end

  describe "#active" do
    it "is not active if it has started already" do
      promotion.starts_at = Time.current - 1.day
      expect(promotion.active?).to eq(false)
    end

    it "is not active if it has not ended yet" do
      promotion.expires_at = Time.current + 1.day
      expect(promotion.active?).to eq(false)
    end

    it "is not active if current time is within starts_at and expires_at range" do
      promotion.starts_at = Time.current - 1.day
      promotion.expires_at = Time.current + 1.day
      expect(promotion.active?).to eq(false)
    end

    it "is not active if there are no start and end times set" do
      promotion.starts_at = nil
      promotion.expires_at = nil
      expect(promotion.active?).to eq(false)
    end

    context "when promotion has an benefit" do
      let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, name: "name1") }

      it "is active if it has started already" do
        promotion.starts_at = Time.current - 1.day
        expect(promotion.active?).to eq(true)
      end

      it "is active if it has not ended yet" do
        promotion.expires_at = Time.current + 1.day
        expect(promotion.active?).to eq(true)
      end

      it "is active if current time is within starts_at and expires_at range" do
        promotion.starts_at = Time.current - 1.day
        promotion.expires_at = Time.current + 1.day
        expect(promotion.active?).to eq(true)
      end

      it "is active if there are no start and end times set" do
        promotion.starts_at = nil
        promotion.expires_at = nil
        expect(promotion.active?).to eq(true)
      end

      context "when called with a time" do
        subject { promotion.active?(1.day.ago) }

        context "if promo was active a day ago" do
          before do
            promotion.starts_at = 2.days.ago
            promotion.expires_at = 1.hour.ago
          end

          it { is_expected.to be true }
        end

        context "if promo was not active a day ago" do
          before do
            promotion.starts_at = 1.hour.ago
            promotion.expires_at = 1.day.from_now
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  describe "#products" do
    let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
    let(:promotion_benefit) { promotion.benefits.first }

    context "when it has product conditions with products associated" do
      let(:promotion_condition) { SolidusPromotions::Conditions::Product.new }

      before do
        promotion_condition.benefit = promotion_benefit
        promotion_condition.products << create(:product)
        promotion_condition.save
      end

      it "has products" do
        expect(promotion.reload.products.size).to eq(1)
      end
    end

    context "when there's no product condition associated" do
      it "does not have products but still return an empty array" do
        expect(promotion.products).to be_blank
      end
    end
  end

  # regression for https://github.com/spree/spree/issues/4059
  # admin form posts the code and path as empty string
  describe "normalize blank values for path" do
    it "will save blank value as nil value instead" do
      promotion = SolidusPromotions::Promotion.create(name: "A promotion", customer_label: "nice", path: "")
      expect(promotion.path).to be_nil
    end
  end

  describe "#used_by?" do
    subject { promotion.used_by? user, [excluded_order] }

    let(:promotion) { create :solidus_promotion, :with_adjustable_benefit }
    let(:user) { create :user }
    let(:order) { create :order_with_line_items, user: user }
    let(:excluded_order) { create :order_with_line_items, user: user }

    before do
      order.user_id = user.id
      order.save!
    end

    context "when the user has used this promo" do
      before do
        order.solidus_order_promotions.create(
          promotion: promotion
        )
        order.recalculate
        order.completed_at = Time.current
        order.save!
      end

      context "when the order is complete" do
        it { is_expected.to be true }

        context "when the promotion was not eligible" do
          before do
            promotion.benefits.first.conditions << SolidusPromotions::Conditions::NthOrder.new(preferred_nth_order: 2)
            order.recalculate
          end

          it { is_expected.to be false }
        end

        context "when the only matching order is the excluded order" do
          let(:excluded_order) { order }

          it { is_expected.to be false }
        end
      end

      context "when the order is not complete" do
        let(:order) { create :order, user: user }

        # The before clause above sets the completed at
        # value for this order
        before { order.update completed_at: nil }

        it { is_expected.to be false }
      end
    end

    context "when the user has not used this promo" do
      it { is_expected.to be false }
    end
  end

  describe ".original_promotion" do
    let(:spree_promotion) { create :promotion, :with_adjustable_action }
    let(:solidus_promotion) { create :solidus_promotion, :with_adjustable_benefit }

    subject { solidus_promotion.original_promotion }

    it "can be migrated from spree" do
      solidus_promotion.original_promotion = spree_promotion
      expect(subject).to eq(spree_promotion)
    end

    it "is ok to be new" do
      expect(subject).to be_nil
    end
  end

  describe "#can_change_apply_automatically?" do
    subject { promotion.can_change_apply_automatically? }

    let(:promotion) { create :solidus_promotion }

    context "when the promotion has a path" do
      before { promotion.path = "foo" }

      it { is_expected.to be false }
    end

    context "when the promotion has a code" do
      before { promotion.codes.new(value: "foo") }

      it { is_expected.to be false }
    end

    context "when the promotion has neither a path nor a code" do
      it { is_expected.to be true }
    end
  end

  describe "#can_change_path?" do
    subject { promotion.can_change_path? }

    let(:promotion) { create :solidus_promotion }

    context "when the promotion has a code" do
      before { promotion.codes.new(value: "foo") }

      it { is_expected.to be false }
    end

    context "when the promotion has a path" do
      before { promotion.path = "foo" }

      it { is_expected.to be true }
    end

    context "when the promotion has neither a path nor a code" do
      it { is_expected.to be true }
    end

    context "when the promotion applies automatically" do
      before { promotion.apply_automatically = true }

      it { is_expected.to be false }
    end
  end

  describe "#can_change_codes?" do
    subject { promotion.can_change_codes? }

    let(:promotion) { create :solidus_promotion }

    context "when the promotion has a code" do
      before { promotion.codes.new(value: "foo") }

      it { is_expected.to be true }
    end

    context "when the promotion has a path" do
      before { promotion.path = "foo" }

      it { is_expected.to be false }
    end

    context "when the promotion has neither a path nor a code" do
      it { is_expected.to be true }
    end

    context "when the promotion applies automatically" do
      before { promotion.apply_automatically = true }

      it { is_expected.to be false }
    end
  end
end
