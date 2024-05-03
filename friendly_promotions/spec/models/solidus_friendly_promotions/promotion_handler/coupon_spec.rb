# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionHandler::Coupon, type: :model do
  let(:order) { double("Order", coupon_code: "10off").as_null_object }

  subject { described_class.new(order) }

  def expect_order_connection(order:, promotion:, promotion_code: nil)
    expect(order.friendly_promotions.to_a).to include(promotion)
    expect(order.friendly_order_promotions.flat_map(&:promotion_code)).to include(promotion_code)
  end

  def expect_adjustment_creation(adjustable:, promotion:, promotion_code: nil)
    expect(adjustable.adjustments.map(&:source).map(&:promotion)).to include(promotion)
  end

  it "returns self in apply" do
    expect(subject.apply).to be_a described_class
  end

  context "status messages" do
    let(:coupon) { described_class.new(order) }

    describe "#set_success_code" do
      let(:status) { :coupon_code_applied }
      subject { coupon.send(:set_success_code, status) }

      it "should have status_code" do
        subject
        expect(coupon.status_code).to eq(status)
      end

      it "should have success message" do
        subject
        expect(coupon.success).to eq "The coupon code was successfully applied to your order."
      end
    end

    describe "#set_error_code" do
      subject { coupon.send(:set_error_code, status) }

      context "not found" do
        let(:status) { :coupon_code_not_found }

        it "has status_code" do
          subject
          expect(coupon.status_code).to eq(status)
        end

        it "has error message" do
          subject
          expect(coupon.error).to eq "The coupon code you entered doesn't exist. Please try again."
        end
      end

      context "not present" do
        let(:status) { :coupon_code_not_present }

        it "has status_code" do
          subject
          expect(coupon.status_code).to eq(status)
        end

        it "has error message" do
          subject
          expect(coupon.error).to eq "The coupon code you are trying to remove is not present on this order."
        end
      end
    end
  end

  context "coupon code promotion doesnt exist" do
    before { create(:promotion) }

    it "doesnt fetch any promotion" do
      expect(subject.promotion).to be_blank
    end

    context "with no actions defined" do
      before { create(:promotion, code: "10off") }

      it "populates error message" do
        subject.apply
        expect(subject.error).to eq "The coupon code you entered doesn't exist. Please try again."
      end
    end
  end

  context "existing coupon code promotion" do
    let!(:promotion) { promotion_code.promotion }
    let(:promotion_code) { create(:friendly_promotion_code, value: "10off") }
    let!(:action) { SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: promotion, calculator: calculator) }
    let(:calculator) { SolidusFriendlyPromotions::Calculators::FlatRate.new(preferred_amount: 10) }

    it "fetches with given code" do
      expect(subject.promotion).to eq promotion
    end

    context "with a per-item adjustment action" do
      let(:order) { create(:order_with_line_items, line_items_count: 3) }

      context "right coupon given" do
        context "with correct coupon code casing" do
          before { order.coupon_code = "10off" }

          it "successfully activates promo" do
            expect(order.total).to eq(130)
            subject.apply
            expect(subject.success).to be_present
            expect_order_connection(order: order, promotion: promotion, promotion_code: promotion_code)
            order.line_items.each do |line_item|
              expect_adjustment_creation(adjustable: line_item, promotion: promotion, promotion_code: promotion_code)
            end
            # Ensure that applying the adjustment actually affects the order's total!
            expect(order.reload.total).to eq(100)
          end

          it "coupon already applied to the order" do
            subject.apply
            expect(subject.success).to be_present
            subject.apply
            expect(subject.error).to eq "The coupon code has already been applied to this order"
          end
        end

        # Regression test for https://github.com/spree/spree/issues/4211
        context "with incorrect coupon code casing" do
          before { order.coupon_code = "10OFF" }
          it "successfully activates promo" do
            expect(order.total).to eq(130)
            subject.apply
            expect(subject.success).to be_present
            expect_order_connection(order: order, promotion: promotion, promotion_code: promotion_code)
            order.line_items.each do |line_item|
              expect_adjustment_creation(adjustable: line_item, promotion: promotion, promotion_code: promotion_code)
            end
            # Ensure that applying the adjustment actually affects the order's total!
            expect(order.reload.total).to eq(100)
          end
        end
      end

      context "coexists with a non coupon code promo" do
        let!(:order) { create(:order) }

        before do
          order.coupon_code = "10off"
          calculator = SolidusFriendlyPromotions::Calculators::FlatRate.new(preferred_amount: 10)
          general_promo = create(:friendly_promotion, lane: :post, apply_automatically: true, name: "General Promo")
          SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: general_promo, calculator: calculator)

          order.contents.add create(:variant)
        end

        # regression spec for https://github.com/spree/spree/issues/4515
        it "successfully activates promo" do
          subject.apply
          expect(subject).to be_successful
          expect_order_connection(order: order, promotion: promotion, promotion_code: promotion_code)
          order.line_items.each do |line_item|
            expect_adjustment_creation(adjustable: line_item, promotion: promotion, promotion_code: promotion_code)
          end
        end
      end

      context "applied alongside another valid promotion " do
        let!(:order) { create(:order) }

        before do
          order.coupon_code = "10off"
          calculator = SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 10)
          general_promo = create(:friendly_promotion, lane: :pre, apply_automatically: true, name: "General Promo")
          SolidusFriendlyPromotions::Actions::AdjustLineItem.create!(promotion: general_promo, calculator: calculator)

          order.contents.add create(:variant, price: 500)
          order.contents.add create(:variant, price: 10)
        end

        it "successfully activates both promotions and returns success" do
          subject.apply
          expect(subject).to be_successful
          order.line_items.each do |line_item|
            expect(line_item.adjustments.count).to eq 2
            expect_adjustment_creation(adjustable: line_item, promotion: promotion, promotion_code: promotion_code)
          end
        end
      end
    end

    context "with a free-shipping adjustment action" do
      let!(:action) do
        SolidusFriendlyPromotions::Actions::AdjustShipment.create!(
          promotion: promotion,
          calculator: calculator
        )
      end
      let(:calculator) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 100) }
      context "right coupon code given" do
        let(:order) { create(:order_with_line_items, line_items_count: 3) }

        before { order.coupon_code = "10off" }

        it "successfully activates promo" do
          expect(order.total).to eq(130)
          subject.apply
          expect(subject.success).to be_present

          expect_order_connection(order: order, promotion: promotion, promotion_code: promotion_code)
          order.shipments.each do |shipment|
            expect_adjustment_creation(adjustable: shipment, promotion: promotion, promotion_code: promotion_code)
          end
        end

        it "coupon already applied to the order" do
          subject.apply
          expect(subject.success).to be_present
          subject.apply
          expect(subject.error).to eq "The coupon code has already been applied to this order"
        end
      end
    end

    context "with a whole-order adjustment action" do
      let!(:action) { SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: promotion, calculator: calculator) }
      context "right coupon given" do
        let(:order) { create(:order) }
        let(:calculator) { SolidusFriendlyPromotions::Calculators::DistributedAmount.new(preferred_amount: 10) }

        before do
          allow(order).to receive_messages({
            coupon_code: "10off",
            # These need to be here so that promotion adjustment "wins"
            item_total: 50,
            ship_total: 10
          })
        end

        it "successfully activates promo" do
          subject.apply
          expect(subject.success).to be_present
          expect(order.all_adjustments.count).to eq(order.line_items.count)
          expect_order_connection(order: order, promotion: promotion, promotion_code: promotion_code)
          order.line_items.each do |line_item|
            expect_adjustment_creation(adjustable: line_item, promotion: promotion, promotion_code: promotion_code)
          end
        end

        context "when the coupon is already applied to the order" do
          before { subject.apply }

          it "is not successful" do
            subject.apply
            expect(subject.successful?).to be false
          end

          it "returns a coupon has already been applied error" do
            subject.apply
            expect(subject.error).to eq "The coupon code has already been applied to this order"
          end
        end

        context "when the coupon fails to activate" do
          let(:impossible_condition) { SolidusFriendlyPromotions::Rules::NthOrder.new(preferred_nth_order: 2) }

          before do
            promotion.actions.first.conditions << impossible_condition
          end

          it "is not successful" do
            subject.apply
            expect(subject.successful?).to be false
          end

          it "returns a coupon failed to activate error" do
            subject.apply
            expect(subject.error).to eq "This coupon code could not be applied to the cart at this time."
          end
        end

        context "when the promotion exceeds its usage limit" do
          let!(:second_order) { FactoryBot.create(:completed_order_with_friendly_promotion, promotion: promotion) }

          before do
            promotion.update!(usage_limit: 1)
            described_class.new(second_order).apply
          end

          it "is not successful" do
            subject.apply
            expect(subject.successful?).to be false
          end

          it "returns a coupon is at max usage error" do
            subject.apply
            expect(subject.error).to eq "Coupon code usage limit exceeded"
          end
        end
      end
    end

    context "for an order with taxable line items" do
      let(:store) { create(:store) }
      let(:order) { create(:order, store: store) }
      let(:tax_category) { create(:tax_category, name: "Taxable Foo") }
      let(:zone) { create(:zone, :with_country) }
      let!(:tax_rate) { create(:tax_rate, amount: 0.1, tax_categories: [tax_category], zone: zone) }

      before(:each) do
        expect(order).to receive(:tax_address).at_least(:once).and_return(Spree::Tax::TaxLocation.new(country: zone.countries.first))
      end

      context "and the product price is less than promo discount" do
        before(:each) do
          order.coupon_code = "10off"

          3.times do |_i|
            taxable = create(:product, tax_category: tax_category, price: 9.0)
            order.contents.add(taxable.master, 1)
          end
        end

        it "successfully applies the promo" do
          # 3 * (9 + 0.9)
          expect(order.total).to eq(29.7)
          coupon = described_class.new(order)
          coupon.apply
          expect(coupon.success).to be_present
          # 3 * ((9 - [9,10].min) + 0)
          expect(order.reload.total).to eq(0)
          expect(order.additional_tax_total).to eq(0)
        end
      end

      context "and the product price is greater than promo discount" do
        before(:each) do
          order.coupon_code = "10off"

          3.times do |_i|
            taxable = create(:product, tax_category: tax_category, price: 11.0)
            order.contents.add(taxable.master, 2)
          end
        end

        it "successfully applies the promo" do
          # 3 * (22 + 2.2)
          expect(order.total.to_f).to eq(72.6)
          coupon = described_class.new(order)
          coupon.apply
          expect(coupon.success).to be_present
          # 3 * ( (22 - 10) + 1.2)
          expect(order.reload.total).to eq(39.6)
          expect(order.additional_tax_total).to eq(3.6)
        end
      end

      context "and multiple quantity per line item" do
        before(:each) do
          twnty_off = create(:friendly_promotion, name: "promo", code: "20off")
          twnty_off_calc = SolidusFriendlyPromotions::Calculators::FlatRate.new(preferred_amount: 20)
          SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: twnty_off,
            calculator: twnty_off_calc)

          order.coupon_code = "20off"

          3.times do |_i|
            taxable = create(:product, tax_category: tax_category, price: 10.0)
            order.contents.add(taxable.master, 2)
          end
        end

        it "successfully applies the promo" do
          # 3 * ((2 * 10) + 2.0)
          expect(order.total.to_f).to eq(66)
          coupon = described_class.new(order)
          coupon.apply
          expect(coupon.success).to be_present
          # 0
          expect(order.reload.total).to eq(0)
          expect(order.additional_tax_total).to eq(0)
        end
      end
    end
  end

  context "removing a coupon code from an order" do
    let!(:promotion) { promotion_code.promotion }
    let(:promotion_code) { create(:friendly_promotion_code, value: "10off") }
    let!(:action) { SolidusFriendlyPromotions::Actions::AdjustLineItem.create(promotion: promotion, calculator: calculator) }
    let(:calculator) { SolidusFriendlyPromotions::Calculators::FlatRate.new(preferred_amount: 10) }
    let(:order) { create(:order_with_line_items, line_items_count: 3) }

    context "with an already applied coupon" do
      before do
        order.coupon_code = "10off"
        subject.apply
        order.reload
        expect(order.total).to eq(100)
      end

      it "successfully removes the coupon code from the order" do
        subject.remove
        expect(subject.error).to eq nil
        expect(subject.success).to eq "The coupon code was successfully removed from this order."
        expect(order.reload.total).to eq(130)
      end
    end

    context "with a coupon code not applied to an order" do
      before do
        order.coupon_code = "10off"
        expect(order.total).to eq(130)
      end

      it "returns an error" do
        subject.remove
        expect(subject.success).to eq nil
        expect(subject.error).to eq "The coupon code you are trying to remove is not present on this order."
        expect(order.reload.total).to eq(130)
      end
    end
  end

  context "with multiple errors" do
    let(:shirt) { create(:product) }
    let(:hat) { create(:product) }
    let(:order) { create(:order_with_line_items, coupon_code: "XMAS", line_items_attributes: [{variant: shirt.master, quantity: 1}]) }
    let(:product_rule) { SolidusFriendlyPromotions::Rules::Product.new(products: [hat], preferred_line_item_applicable: false) }
    let(:nth_order_rule) { SolidusFriendlyPromotions::Rules::NthOrder.new(preferred_nth_order: 2) }
    let(:ten_off_items) { SolidusFriendlyPromotions::Calculators::Percent.create!(preferred_percent: 10) }
    let(:line_item_action) { SolidusFriendlyPromotions::Actions::AdjustLineItem.new(calculator: ten_off_items, conditions: conditions) }
    let(:actions) { [line_item_action] }
    let(:conditions) { [product_rule, nth_order_rule] }
    let!(:promotion) { create(:friendly_promotion, actions: actions, name: "10% off Shirts and USPS Shipping") }
    let!(:coupon) { create(:friendly_promotion_code, promotion: promotion, value: "XMAS") }
    let(:handler) { described_class.new(order) }

    subject { handler.apply }

    it "is unsuccessful with multiple errors" do
      subject
      expect(handler.success).to be nil
      # Promotion rules are not ordered, so it can be either of these errors.
      expect(handler.error).to be_in([
        "You need to add an applicable product before applying this coupon code.",
        "This coupon code could not be applied to the cart at this time."
      ])
      expect(handler.errors).to contain_exactly(
        "You need to add an applicable product before applying this coupon code.",
        "This coupon code could not be applied to the cart at this time."
      )
    end
  end
end
