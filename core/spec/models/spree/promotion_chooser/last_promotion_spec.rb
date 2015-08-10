require 'spec_helper'

describe Spree::PromotionChooser::LastPromotion do
  let(:order) { create :order_with_line_items, line_items_count: 1 }
  let(:line_item) { order.line_items.first }
  let(:calculator) { Spree::Calculator::FlatRate.new(preferred_amount: 10) }

  let(:source) do
    Spree::Promotion::Actions::CreateItemAdjustments.create!(
      calculator: calculator,
      promotion: promotion,
    )
  end
  let(:promotion) { create(:promotion) }

  let(:adjustments) { [] }
  let(:chooser) { Spree::PromotionChooser::LastPromotion.new(adjustments) }

  before do
    Spree::ItemAdjustments.promotion_chooser_class = Spree::PromotionChooser::LastPromotion
  end

  def create_adjustment(label, amount)
    create(:adjustment, order:      order,
                        adjustable: line_item,
                        source:     source,
                        amount:     amount,
                        state:      "closed",
                        label:      label,
                        mandatory:  false)
  end

  describe ".update" do
    subject { chooser.update }

    it "should make all but the most recently applied promotion adjustment ineligible, leaving non promotion adjustments alone" do
      adjustments << create_adjustment("Promotion A", -300)
      adjustments << create_adjustment("Promotion B", -200)
      adjustments << create_adjustment("Promotion C", -1)
      adjustments << create(:adjustment, order: order,
                                         adjustable: line_item,
                                         source: nil,
                                         amount: -500,
                                         state: "closed",
                                         label: "Some other credit")
      line_item.adjustments.update_all(eligible: true)

      subject

      expect(line_item.adjustments.promotion.eligible.count).to eq(1)
      expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion C')
    end

    it "should only leave one adjustment even if 2 have the same amount" do
      adjustments << create_adjustment("Promotion A", -100)
      adjustments << create_adjustment("Promotion B", -200)
      adjustments << create_adjustment("Promotion C", -200)

      subject

      expect(line_item.adjustments.promotion.eligible.count).to eq(1)
      expect(line_item.adjustments.promotion.eligible.first.amount.to_i).to eq(-200)
    end

    context "multiple adjustments and the most recently applied is not eligible" do
      let!(:promo_a) { create_adjustment("Promotion A", -100) }
      let!(:promo_c) { create_adjustment("Promotion C", -300) }

      before do
        promo_a.update_columns(eligible: true)
        promo_c.update_columns(eligible: false)
        adjustments << promo_a
        adjustments << promo_c
      end

      # regression for #3274
      it "still makes the previous best eligible adjustment valid" do
        subject
        expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion A')
      end
    end
  end

  context "when previously ineligible promotions become available" do
    let(:order_promo1) { create(:promotion, :with_order_adjustment, :with_item_total_rule, weighted_order_adjustment_amount: 5, item_total_threshold_amount: 10) }
    let(:order_promo2) { create(:promotion, :with_order_adjustment, :with_item_total_rule, weighted_order_adjustment_amount: 10, item_total_threshold_amount: 20) }
    let(:order_promo3) { create(:promotion, :with_order_adjustment, :with_item_total_rule, weighted_order_adjustment_amount: 2, item_total_threshold_amount: 20) }
    let(:line_item_promo1) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 2.5, item_total_threshold_amount: 10) }
    let(:line_item_promo2) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 5, item_total_threshold_amount: 20) }
    let(:line_item_promo3) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 1, item_total_threshold_amount: 20) }
    let(:order) { create(:order_with_line_items, line_items_count: 1) }

    it "should pick the most recent order-level promo according to current eligibility" do
      # apply both promos to the order, even though only order_promo1 is eligible
      order_promo1.activate order: order
      order_promo2.activate order: order
      order_promo3.activate order: order

      order.reload
      expect(order.all_adjustments.count).to eq(3), "Expected three adjustments"
      expect(order.all_adjustments.eligible.count).to eq(1), "Expected one elegible adjustment"
      expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo1), "Expected promo1 to be used"

      order.contents.add create(:variant, price: 10), 1
      order.save

      order.reload
      expect(order.all_adjustments.count).to eq(3), "Expected three adjustments"
      expect(order.all_adjustments.eligible.count).to eq(1), "Expected one eligible adjustments"
      expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo3), "Expected promo3 to be used"
    end

    it "should pick the most recently applied line-item-level promo according to current eligibility" do
      # apply both promos to the order, even though only line_item_promo1 is eligible
      line_item_promo1.activate order: order
      line_item_promo2.activate order: order
      line_item_promo3.activate order: order

      order.reload
      expect(order.all_adjustments.count).to eq(1), "Expected one adjustment"
      expect(order.all_adjustments.eligible.count).to eq(1), "Expected one eligible adjustment"
      # line_item_promo1 is the only one that has thus far met the order total threshold, it is the only promo which should be applied.
      expect(order.all_adjustments.first.source.promotion).to eq(line_item_promo1), "Expected line_item_promo1 to be used"

      order.contents.add create(:variant, price: 10), 1
      order.save

      order.reload
      expect(order.all_adjustments.count).to eq(6), "Expected six adjustments"
      expect(order.all_adjustments.eligible.count).to eq(2), "Expected two eligible adjustments"
      order.all_adjustments.eligible.each do |adjustment|
        expect(adjustment.source.promotion).to eq(line_item_promo3), "Expected line_item_promo3 to be used"
      end
    end
  end
end
