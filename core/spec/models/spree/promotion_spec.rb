# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion, type: :model do
  let(:promotion) { Spree::Promotion.new }

  describe "validations" do
    before :each do
      @valid_promotion = Spree::Promotion.new name: "A promotion"
    end

    it "valid_promotion is valid" do
      expect(@valid_promotion).to be_valid
    end

    it "validates usage limit" do
      @valid_promotion.usage_limit = -1
      expect(@valid_promotion).not_to be_valid

      @valid_promotion.usage_limit = 100
      expect(@valid_promotion).to be_valid
    end

    it "validates name" do
      @valid_promotion.name = nil
      expect(@valid_promotion).not_to be_valid
    end
  end

  describe ".applied" do
    it "scopes promotions that have been applied to an order only" do
      promotion = Spree::Promotion.create! name: "test"
      expect(Spree::Promotion.applied).to be_empty

      promotion.orders << create(:order)
      expect(Spree::Promotion.applied.first).to eq promotion
    end
  end

  describe ".advertised" do
    let(:promotion) { create(:promotion) }
    let(:advertised_promotion) { create(:promotion, advertise: true) }

    it "only shows advertised promotions" do
      advertised = Spree::Promotion.advertised
      expect(advertised).to include(advertised_promotion)
      expect(advertised).not_to include(promotion)
    end
  end

  describe ".coupons" do
    let(:promotion_code) { create(:promotion_code) }
    let!(:promotion_with_code) { promotion_code.promotion }
    let!(:another_promotion_code) { create(:promotion_code, promotion: promotion_with_code) }
    let!(:promotion_without_code) { create(:promotion) }

    subject { described_class.coupons }

    it "returns only distinct promotions with a code associated" do
      expect(subject).to eq [promotion_with_code]
    end
  end

  describe "#apply_automatically" do
    subject { build(:promotion) }

    it "defaults to false" do
      expect(subject.apply_automatically).to eq(false)
    end

    context "when set to true" do
      before { subject.apply_automatically = true }

      it "should remain valid" do
        expect(subject).to be_valid
      end

      it "invalidates the promotion when it has a code" do
        subject.codes.build(value: "foo")
        expect(subject).to_not be_valid
        expect(subject.errors).to include(:apply_automatically)
      end

      it "invalidates the promotion when it has a path" do
        subject.path = "foo"
        expect(subject).to_not be_valid
        expect(subject.errors).to include(:apply_automatically)
      end
    end
  end

  describe "#save" do
    let(:promotion) { Spree::Promotion.create(name: "delete me") }

    before(:each) do
      promotion.actions << Spree::Promotion::Actions::CreateAdjustment.new
      promotion.rules << Spree::Promotion::Rules::FirstOrder.new
      promotion.save!
    end

    it "should deeply autosave records and preferences" do
      promotion.actions[0].calculator.preferred_flat_percent = 10
      promotion.save!
      expect(Spree::Calculator.first.preferred_flat_percent).to eq(10)
    end
  end

  describe "#activate" do
    let(:promotion) { create(:promotion) }

    before do
      @action1 = Spree::Promotion::Actions::CreateAdjustment.create!
      @action2 = Spree::Promotion::Actions::CreateAdjustment.create!
      allow(@action1).to receive_messages perform: true
      allow(@action2).to receive_messages perform: true

      promotion.promotion_actions = [@action1, @action2]
      promotion.created_at = 2.days.ago

      @user = create(:user)
      @order = create(:order, user: @user, created_at: Time.current)
      @payload = { order: @order, user: @user }
    end

    it "should check path if present" do
      promotion.path = 'content/cvv'
      @payload[:path] = 'content/cvv'
      expect(@action1).to receive(:perform).with(hash_including(@payload))
      expect(@action2).to receive(:perform).with(hash_including(@payload))
      promotion.activate(@payload)
    end

    it "does not perform actions against an order in a finalized state" do
      expect(@action1).not_to receive(:perform)

      @order.state = 'complete'
      promotion.activate(@payload)

      @order.state = 'awaiting_return'
      promotion.activate(@payload)

      @order.state = 'returned'
      promotion.activate(@payload)
    end

    it "does activate if newer then order" do
      expect(@action1).to receive(:perform).with(hash_including(@payload))
      promotion.created_at = Time.current + 2
      expect(promotion.activate(@payload)).to be true
    end

    context "keeps track of the orders" do
      context "when activated" do
        it "assigns the order" do
          expect(promotion.orders).to be_empty
          expect(promotion.activate(@payload)).to be true
          expect(promotion.orders.first).to eql @order
        end

        it 'keeps in-memory associations updated' do
          # load all the relevant associations into memory
          promotion.order_promotions.to_a
          promotion.orders.to_a
          @order.order_promotions.to_a
          @order.promotions.to_a

          expect(promotion.order_promotions.size).to eq(0)
          expect(promotion.orders.size).to eq(0)
          expect(@order.order_promotions.size).to eq(0)
          expect(@order.promotions.size).to eq(0)

          expect(
            promotion.activate(@payload)
          ).to eq(true)

          aggregate_failures do
            expect(promotion.order_promotions.size).to eq(1)
            expect(promotion.orders.size).to eq(1)
            expect(@order.order_promotions.size).to eq(1)
            expect(@order.promotions.size).to eq(1)
          end
        end
      end
      context "when not activated" do
        it "will not assign the order" do
          @order.state = 'complete'
          expect(promotion.orders).to be_empty
          expect(promotion.activate(@payload)).to be_falsey
          expect(promotion.orders).to be_empty
        end
      end
      context "when the order is already associated" do
        before do
          expect(promotion.orders).to be_empty
          expect(promotion.activate(@payload)).to be true
          expect(promotion.orders.to_a).to eql [@order]
        end

        it "will not assign the order again" do
          expect(promotion.activate(@payload)).to be true
          expect(promotion.orders.reload.to_a).to eql [@order]
        end
      end
    end

    context "when there is a code" do
      let(:promotion_code) { create(:promotion_code) }
      let(:promotion) { promotion_code.promotion }

      it "assigns the code" do
        expect(promotion.activate(order: @order, promotion_code: promotion_code)).to be true
        expect(promotion.order_promotions.map(&:promotion_code)).to eq [promotion_code]
      end
    end
  end

  describe '#remove_from' do
    let(:promotion) { create(:promotion, :with_line_item_adjustment) }
    let(:order) { create(:order_with_line_items) }

    before do
      promotion.activate(order: order)
    end

    it 'removes the promotion' do
      expect(order.promotions).to include(promotion)
      expect(order.line_items.flat_map(&:adjustments)).to be_present

      promotion.remove_from(order)

      expect(order.promotions).to be_empty
      expect(order.line_items.flat_map(&:adjustments)).to be_empty
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
                :completed_order_with_promotion,
                promotion: promotion
              )
              promotion.actions.first.adjustments.update_all(eligible: true)
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

    context "with an order-level adjustment" do
      let(:promotion) do
        FactoryBot.create(
          :promotion,
          :with_order_adjustment,
          code: "discount",
          usage_limit: usage_limit
        )
      end
      let(:promotable) do
        FactoryBot.create(
          :completed_order_with_promotion,
          promotion: promotion
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
          usage_limit: usage_limit
        )
      end
      before do
        promotion.actions.first.perform({
          order: order,
          promotion: promotion,
          promotion_code: promotion.codes.first
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

  describe "#usage_count" do
    let(:promotion) do
      FactoryBot.create(
        :promotion,
        :with_order_adjustment,
        code: "discount"
      )
    end

    subject { promotion.usage_count }

    context "when the code is applied to a non-complete order" do
      let(:order) { FactoryBot.create(:order_with_line_items) }
      before { promotion.activate(order: order, promotion_code: promotion.codes.first) }
      it { is_expected.to eq 0 }
    end
    context "when the code is applied to a complete order" do
      let!(:order) do
        FactoryBot.create(
          :completed_order_with_promotion,
          promotion: promotion
        )
      end
      context "and the promo is eligible" do
        it { is_expected.to eq 1 }
      end
      context "and the promo is ineligible" do
        before { order.adjustments.promotion.update_all(eligible: false) }
        it { is_expected.to eq 0 }
      end
    end
  end

  context "#inactive" do
    it "should not be exipired" do
      expect(promotion).not_to be_inactive
    end

    it "should be inactive if it hasn't started yet" do
      promotion.starts_at = Time.current + 1.day
      expect(promotion).to be_inactive
    end

    it "should be inactive if it has already ended" do
      promotion.expires_at = Time.current - 1.day
      expect(promotion).to be_inactive
    end

    it "should not be inactive if it has started already" do
      promotion.starts_at = Time.current - 1.day
      expect(promotion).not_to be_inactive
    end

    it "should not be inactive if it has not ended yet" do
      promotion.expires_at = Time.current + 1.day
      expect(promotion).not_to be_inactive
    end

    it "should not be inactive if current time is within starts_at and expires_at range" do
      promotion.starts_at = Time.current - 1.day
      promotion.expires_at = Time.current + 1.day
      expect(promotion).not_to be_inactive
    end
  end

  describe '#not_started?' do
    let(:promotion) { Spree::Promotion.new(starts_at: starts_at) }
    subject { promotion.not_started? }

    context 'no starts_at date' do
      let(:starts_at) { nil }
      it { is_expected.to be_falsey }
    end

    context 'when starts_at date is in the past' do
      let(:starts_at) { Time.current - 1.day }
      it { is_expected.to be_falsey }
    end

    context 'when starts_at date is not already reached' do
      let(:starts_at) { Time.current + 1.day }
      it { is_expected.to be_truthy }
    end
  end

  describe '#started?' do
    let(:promotion) { Spree::Promotion.new(starts_at: starts_at) }
    subject { promotion.started? }

    context 'when no starts_at date' do
      let(:starts_at) { nil }
      it { is_expected.to be_truthy }
    end

    context 'when starts_at date is in the past' do
      let(:starts_at) { Time.current - 1.day }
      it { is_expected.to be_truthy }
    end

    context 'when starts_at date is not already reached' do
      let(:starts_at) { Time.current + 1.day }
      it { is_expected.to be_falsey }
    end
  end

  describe '#expired?' do
    let(:promotion) { Spree::Promotion.new(expires_at: expires_at) }
    subject { promotion.expired? }

    context 'when no expires_at date' do
      let(:expires_at) { nil }
      it { is_expected.to be_falsey }
    end

    context 'when expires_at date is not already reached' do
      let(:expires_at) { Time.current + 1.day }
      it { is_expected.to be_falsey }
    end

    context 'when expires_at date is in the past' do
      let(:expires_at) { Time.current - 1.day }
      it { is_expected.to be_truthy }
    end
  end

  describe '#not_expired?' do
    let(:promotion) { Spree::Promotion.new(expires_at: expires_at) }
    subject { promotion.not_expired? }

    context 'when no expired_at date' do
      let(:expires_at) { nil }
      it { is_expected.to be_truthy }
    end

    context 'when expires_at date is not already reached' do
      let(:expires_at) { Time.current + 1.day }
      it { is_expected.to be_truthy }
    end

    context 'when expires_at date is in the past' do
      let(:expires_at) { Time.current - 1.day }
      it { is_expected.to be_falsey }
    end
  end

  context "#active" do
    it "should be active" do
      expect(promotion.active?).to eq(true)
    end

    it "should not be active if it hasn't started yet" do
      promotion.starts_at = Time.current + 1.day
      expect(promotion.active?).to eq(false)
    end

    it "should not be active if it has already ended" do
      promotion.expires_at = Time.current - 1.day
      expect(promotion.active?).to eq(false)
    end

    it "should be active if it has started already" do
      promotion.starts_at = Time.current - 1.day
      expect(promotion.active?).to eq(true)
    end

    it "should be active if it has not ended yet" do
      promotion.expires_at = Time.current + 1.day
      expect(promotion.active?).to eq(true)
    end

    it "should be active if current time is within starts_at and expires_at range" do
      promotion.starts_at = Time.current - 1.day
      promotion.expires_at = Time.current + 1.day
      expect(promotion.active?).to eq(true)
    end

    it "should be active if there are no start and end times set" do
      promotion.starts_at = nil
      promotion.expires_at = nil
      expect(promotion.active?).to eq(true)
    end
  end

  context "#usage_count" do
    let!(:promotion) do
      create(
        :promotion,
        name: "Foo",
        code: "XXX"
      )
    end

    let!(:action) do
      calculator = Spree::Calculator::FlatRate.new
      action_params = { promotion: promotion, calculator: calculator }
      action = Spree::Promotion::Actions::CreateAdjustment.create(action_params)
      promotion.actions << action
      action
    end

    let!(:adjustment) do
      order = create(:order)
      Spree::Adjustment.create!(
        order:      order,
        adjustable: order,
        source:     action,
        promotion_code: promotion.codes.first,
        amount:     10,
        label:      'Promotional adjustment'
      )
    end

    it "counts eligible adjustments" do
      adjustment.update_column(:eligible, true)
      expect(promotion.usage_count).to eq(0)
    end

    # Regression test for https://github.com/spree/spree/issues/4112
    it "does not count ineligible adjustments" do
      adjustment.update_column(:eligible, false)
      expect(promotion.usage_count).to eq(0)
    end
  end

  context "#products" do
    let(:promotion) { create(:promotion) }

    context "when it has product rules with products associated" do
      let(:promotion_rule) { Spree::Promotion::Rules::Product.new }

      before do
        promotion_rule.promotion = promotion
        promotion_rule.products << create(:product)
        promotion_rule.save
      end

      it "should have products" do
        expect(promotion.reload.products.size).to eq(1)
      end
    end

    context "when there's no product rule associated" do
      it "should not have products but still return an empty array" do
        expect(promotion.products).to be_blank
      end
    end
  end

  context "#eligible?" do
    subject do
      promotion.eligible?(promotable, promotion_code: promotion.codes.first)
    end

    shared_examples "a promotable" do
      context "when empty" do
        it { is_expected.to be true }
      end

      context "when promotion is expired" do
        before { promotion.expires_at = Time.current - 10.days }

        it { is_expected.to be false }
      end

      context "when promotion's usage limit is exceeded" do
        before do
          promotion.usage_limit = 1
          create(:completed_order_with_promotion, promotion: promotion)
        end

        it { is_expected.to be false }
      end

      context "when promotion code's usage limit is exceeded" do
        before do
          promotion.per_code_usage_limit = 1
          create(:completed_order_with_promotion, promotion: promotion)
          promotion.codes.first.adjustments.update_all(eligible: true)
        end

        it { is_expected.to be false }
      end

      context "when promotion is at last usage on the same order" do
        let(:order) { create(:completed_order_with_promotion, promotion: promotion) }
        let(:promotable) { order }

        before do
          promotion.usage_limit = 1
        end

        it { is_expected.to be true }
      end

      context "when promotion code is at last usage on the same order" do
        let(:order) { create(:completed_order_with_promotion, promotion: promotion) }
        let(:promotable) { order }

        before do
          promotion.per_code_usage_limit = 1
        end

        it { is_expected.to be true }
      end
    end

    context "when promotable is a Spree::Order" do
      let(:promotion) { create(:promotion, :with_order_adjustment) }
      let(:promotable) { create :order }

      it_behaves_like "a promotable"

      context "when it contains items" do
        let!(:line_item) { create(:line_item, order: promotable) }
        let!(:line_item2) { create(:line_item, order: promotable) }

        context "and at least one item is non-promotionable" do
          before do
            line_item.product.update_column(:promotionable, false)
          end

          it { is_expected.to be false }
        end

        context "and the items are all non-promotionable" do
          before do
            line_item.product.update_column(:promotionable, false)
            line_item2.product.update_column(:promotionable, false)
          end

          it { is_expected.to be false }
        end

        context "and at least one item is promotionable" do
          it { is_expected.to be true }
        end
      end
    end

    context "when promotable is a Spree::LineItem" do
      let(:promotion) { create(:promotion, :with_line_item_adjustment) }
      let(:promotable) { create(:line_item) }

      it_behaves_like "a promotable"

      context "and product is promotionable" do
        before { promotable.product.promotionable = true }

        it { is_expected.to be true }
      end

      context "and product is not promotionable" do
        before { promotable.product.promotionable = false }

        it { is_expected.to be false }
      end
    end

    context "when promotable is a Spree::Shipment" do
      let(:promotion) { create(:promotion, :with_free_shipping) }
      let(:promotable) { create(:shipment) }

      it_behaves_like "a promotable"
    end
  end

  context "#eligible_rules" do
    let(:promotable) { double('Promotable') }
    it "true if there are no rules" do
      expect(promotion.eligible_rules(promotable)).to eq []
    end

    it "true if there are no applicable rules" do
      promotion.promotion_rules = [stub_model(Spree::PromotionRule, eligible?: true, applicable?: false)]
      allow(promotion.promotion_rules).to receive(:for).and_return([])
      expect(promotion.eligible_rules(promotable)).to eq []
    end

    context "with 'all' match policy" do
      let(:rule1) { Spree::PromotionRule.create!(promotion: promotion) }
      let(:rule2) { Spree::PromotionRule.create!(promotion: promotion) }

      before { promotion.match_policy = 'all' }

      context "when all rules are eligible" do
        before do
          allow(rule1).to receive_messages(eligible?: true, applicable?: true)
          allow(rule2).to receive_messages(eligible?: true, applicable?: true)

          promotion.promotion_rules = [rule1, rule2]
          allow(promotion).to receive_message_chain(:rules, :none?).and_return(false)
          allow(promotion).to receive_message_chain(:rules, :for).and_return(promotion.promotion_rules)
        end
        it "returns the eligible rules" do
          expect(promotion.eligible_rules(promotable)).to eq [rule1, rule2]
        end
        it "does set anything to eligiblity errors" do
          promotion.eligible_rules(promotable)
          expect(promotion.eligibility_errors).to be_nil
        end
      end

      context "when any of the rules is not eligible" do
        let(:errors) { double ActiveModel::Errors, empty?: false }
        before do
          allow(rule1).to receive_messages(eligible?: true, applicable?: true, eligibility_errors: nil)
          allow(rule2).to receive_messages(eligible?: false, applicable?: true, eligibility_errors: errors)

          promotion.promotion_rules = [rule1, rule2]
          allow(promotion).to receive_message_chain(:rules, :none?).and_return(false)
          allow(promotion).to receive_message_chain(:rules, :for).and_return(promotion.promotion_rules)
        end
        it "returns nil" do
          expect(promotion.eligible_rules(promotable)).to be_nil
        end
        it "sets eligibility errors to the first non-nil one" do
          promotion.eligible_rules(promotable)
          expect(promotion.eligibility_errors).to eq errors
        end
      end
    end

    context "with 'any' match policy" do
      let(:promotable) { double('Promotable') }

      before do
        promotion.match_policy = 'any'
      end

      it "should have eligible rules if any of the rules are eligible" do
        true_rule = mock_model(Spree::PromotionRule, eligible?: true, applicable?: true)
        promotion.promotion_rules = [true_rule]
        allow(promotion.rules).to receive(:for) { promotion.rules }
        expect(promotion.eligible_rules(promotable)).to eq [true_rule]
      end

      context "when none of the rules are eligible" do
        let(:rule) { Spree::PromotionRule.create!(promotion: promotion) }
        let(:errors) { double ActiveModel::Errors, empty?: false }
        before do
          allow(rule).to receive_messages(eligible?: false, applicable?: true, eligibility_errors: errors)

          promotion.promotion_rules = [rule]
          allow(promotion).to receive_message_chain(:rules, :for).and_return(promotion.promotion_rules)
          allow(promotion).to receive_message_chain(:rules, :none?).and_return(false)
        end
        it "returns nil" do
          expect(promotion.eligible_rules(promotable)).to be_nil
        end
        it "sets eligibility errors to the first non-nil one" do
          promotion.eligible_rules(promotable)
          expect(promotion.eligibility_errors).to eq errors
        end
      end
    end
  end

  describe '#line_item_actionable?' do
    let(:order) { double Spree::Order }
    let(:line_item) { double Spree::LineItem }
    let(:true_rule) { mock_model Spree::PromotionRule, eligible?: true, applicable?: true, actionable?: true }
    let(:false_rule) { mock_model Spree::PromotionRule, eligible?: true, applicable?: true, actionable?: false }
    let(:rules) { [] }

    before do
      promotion.promotion_rules = rules
      allow(promotion.rules).to receive(:for) { rules }
    end

    subject { promotion.line_item_actionable? order, line_item }

    context 'when the order is eligible for promotion' do
      context 'when there are no rules' do
        it { is_expected.to be }
      end

      context 'when there are rules' do
        context 'when the match policy is all' do
          before { promotion.match_policy = 'all' }

          context 'when all rules allow action on the line item' do
            let(:rules) { [true_rule] }
            it { is_expected.to be }
          end

          context 'when at least one rule does not allow action on the line item' do
            let(:rules) { [true_rule, false_rule] }
            it { is_expected.not_to be }
          end
        end

        context 'when the match policy is any' do
          before { promotion.match_policy = 'any' }

          context 'when at least one rule allows action on the line item' do
            let(:rules) { [true_rule, false_rule] }
            it { is_expected.to be }
          end

          context 'when no rules allow action on the line item' do
            let(:rules) { [false_rule] }
            it { is_expected.not_to be }
          end
        end

        context 'when the line item has an non-promotionable product' do
          let(:rules) { [true_rule] }
          let(:line_item) { build(:line_item) { |li| li.product.promotionable = false } }
          it { is_expected.not_to be }
        end
      end
    end

    context 'when the order is not eligible for the promotion' do
      context "due to promotion expiration" do
        before { promotion.starts_at = Time.current + 2.days }
        it { is_expected.not_to be }
      end

      context "due to promotion code not being eligible" do
        let(:order) { create(:order) }
        let(:promotion) { create(:promotion, per_code_usage_limit: 0) }
        let(:promotion_code) { create(:promotion_code, promotion: promotion) }

        subject { promotion.line_item_actionable? order, line_item, promotion_code: promotion_code }

        it "returns false" do
          expect(subject).to eq false
        end
      end
    end
  end

  # regression for https://github.com/spree/spree/issues/4059
  # admin form posts the code and path as empty string
  describe "normalize blank values for path" do
    it "will save blank value as nil value instead" do
      promotion = Spree::Promotion.create(name: "A promotion", path: "")
      expect(promotion.path).to be_nil
    end
  end

  describe '#used_by?' do
    subject { promotion.used_by? user, [excluded_order] }

    let(:promotion) { create :promotion, :with_order_adjustment }
    let(:user) { create :user }
    let(:order) { create :order_with_line_items, user: user }
    let(:excluded_order) { create :order_with_line_items, user: user }

    before do
      order.user_id = user.id
      order.save!
    end

    context 'when the user has used this promo' do
      before do
        promotion.activate(order: order)
        order.recalculate
        order.completed_at = Time.current
        order.save!
      end

      context 'when the order is complete' do
        it { is_expected.to be true }

        context 'when the promotion was not eligible' do
          let(:adjustment) { order.adjustments.first }

          before do
            adjustment.eligible = false
            adjustment.save!
          end

          it { is_expected.to be false }
        end

        context 'when the only matching order is the excluded order' do
          let(:excluded_order) { order }
          it { is_expected.to be false }
        end
      end

      context 'when the order is not complete' do
        let(:order) { create :order, user: user }

        # The before clause above sets the completed at
        # value for this order
        before { order.update completed_at: nil }

        it { is_expected.to be false }
      end
    end

    context 'when the user has not used this promo' do
      it { is_expected.to be false }
    end
  end

  describe "adding items to the cart" do
    let(:order) { create :order }
    let(:line_item) { create :line_item, order: order }
    let(:promo) { create :promotion_with_item_adjustment, adjustment_rate: 5, code: 'promo' }
    let(:promotion_code) { promo.codes.first }
    let(:variant) { create :variant }

    it "updates the promotions for new line items" do
      expect(line_item.adjustments).to be_empty
      expect(order.adjustment_total).to eq 0

      promo.activate order: order, promotion_code: promotion_code
      order.recalculate

      expect(line_item.adjustments.size).to eq(1)
      expect(order.adjustment_total).to eq(-5)

      other_line_item = order.contents.add(variant, 1, currency: order.currency)

      expect(other_line_item).not_to eq line_item
      expect(other_line_item.adjustments.size).to eq(1)
      expect(order.adjustment_total).to eq(-10)
    end
  end
end
