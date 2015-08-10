require 'spec_helper'

describe Spree::PromotionChooser::BestPromotion do
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
  let(:chooser) { Spree::PromotionChooser::BestPromotion.new(adjustments) }

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

    it "should make all but the most valuable promotion adjustment ineligible, leaving non promotion adjustments alone" do
      adjustments << create_adjustment("Promotion A", -100)
      adjustments << create_adjustment("Promotion B", -200)
      adjustments << create_adjustment("Promotion C", -300)
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

    it "should choose the most recent promotion adjustment when amounts are equal" do
      # Using Timecop is a regression test
      Timecop.freeze do
        adjustments << create_adjustment("Promotion A", -200)
        adjustments << create_adjustment("Promotion B", -200)
      end
      line_item.adjustments.update_all(eligible: true)

      subject

      expect(line_item.adjustments.promotion.eligible.count).to eq(1)
      expect(line_item.adjustments.promotion.eligible.first.label).to eq('Promotion B')
    end

    it "should only leave one adjustment even if 2 have the same amount" do
      adjustments << create_adjustment("Promotion A", -100)
      adjustments << create_adjustment("Promotion B", -200)
      adjustments << create_adjustment("Promotion C", -200)

      subject

      expect(line_item.adjustments.promotion.eligible.count).to eq(1)
      expect(line_item.adjustments.promotion.eligible.first.amount.to_i).to eq(-200)
    end

    context "multiple adjustments and the best one is not eligible" do
      let!(:promo_a) { create_adjustment("Promotion A", -100) }
      let!(:promo_c) { create_adjustment("Promotion C", -300) }

      before do
        promo_a.update_column(:eligible, true)
        promo_c.update_column(:eligible, false)
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
    let(:order_promos) { [ order_promo1, order_promo2, order_promo3 ] }
    let(:line_item_promo1) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 2.5, item_total_threshold_amount: 10) }
    let(:line_item_promo2) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 5, item_total_threshold_amount: 20) }
    let(:line_item_promo3) { create(:promotion, :with_line_item_adjustment, :with_item_total_rule, adjustment_rate: 1, item_total_threshold_amount: 20) }
    let(:line_item_promos) { [ line_item_promo1, line_item_promo2, line_item_promo3 ] }
    let(:order) { create(:order_with_line_items, line_items_count: 1) }

    # Apply promotions in different sequences. Results should be the same.
    promo_sequences = [
      [ 0, 1, 2 ],
      [ 2, 0, 1 ]
    ]

    promo_sequences.each do |promo_sequence|
      it "should pick the best order-level promo according to current eligibility" do
        # apply all promos to the order, even though only promo1 is eligible
        order_promos[promo_sequence[0]].activate order: order
        order_promos[promo_sequence[1]].activate order: order
        order_promos[promo_sequence[2]].activate order: order

        order.reload
        expect(order.all_adjustments.count).to eq(3), "Expected three adjustments (using sequence #{promo_sequence})"
        expect(order.all_adjustments.eligible.count).to eq(1), "Expected one elegible adjustment (using sequence #{promo_sequence})"
        expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo1), "Expected promo1 to be used (using sequence #{promo_sequence})"

        order.contents.add create(:variant, price: 10), 1
        order.save

        order.reload
        expect(order.all_adjustments.count).to eq(3), "Expected three adjustments (using sequence #{promo_sequence})"
        expect(order.all_adjustments.eligible.count).to eq(1), "Expected one elegible adjustment (using sequence #{promo_sequence})"
        expect(order.all_adjustments.eligible.first.source.promotion).to eq(order_promo2), "Expected promo2 to be used (using sequence #{promo_sequence})"
      end
    end

    promo_sequences.each do |promo_sequence|
      it "should pick the best line-item-level promo according to current eligibility" do
        # apply all promos to the order, even though only promo1 is eligible
        line_item_promos[promo_sequence[0]].activate order: order
        line_item_promos[promo_sequence[1]].activate order: order
        line_item_promos[promo_sequence[2]].activate order: order

        order.reload
        expect(order.all_adjustments.count).to eq(1), "Expected one adjustment (using sequence #{promo_sequence})"
        expect(order.all_adjustments.eligible.count).to eq(1), "Expected one elegible adjustment (using sequence #{promo_sequence})"
        # line_item_promo1 is the only one that has thus far met the order total threshold, it is the only promo which should be applied.
        expect(order.all_adjustments.first.source.promotion).to eq(line_item_promo1), "Expected line_item_promo1 to be used (using sequence #{promo_sequence})"

        order.contents.add create(:variant, price: 10), 1
        order.save

        order.reload
        expect(order.all_adjustments.count).to eq(6), "Expected six adjustments (using sequence #{promo_sequence})"
        expect(order.all_adjustments.eligible.count).to eq(2), "Expected two elegible adjustments (using sequence #{promo_sequence})"
        order.all_adjustments.eligible.each do |adjustment|
          expect(adjustment.source.promotion).to eq(line_item_promo2), "Expected line_item_promo2 to be used (using sequence #{promo_sequence})"
        end
      end
    end
  end
end
