require 'spec_helper'

module Spree
  module PromotionHandler
    describe FreeShipping, type: :model do
      let(:order) { create(:order_with_line_items) }
      let(:shipment) { order.shipments.first }

      let(:action) { Spree::Promotion::Actions::FreeShipping.new }

      subject { Spree::PromotionHandler::FreeShipping.new(order) }

      context 'with apply_automatically' do
        let!(:promotion) { create(:promotion, apply_automatically: true, promotion_actions: [action]) }

        it "creates the adjustment" do
          expect { subject.activate }.to change { shipment.adjustments.count }.by(1)
        end
      end

      context 'with a rule that has not been satisfied' do
        let!(:promotion) do
          create(:promotion, :with_item_total_rule, apply_automatically: true,
                                                    promotion_actions: [action],
                                                    item_total_threshold_amount: order.item_total * 2)
        end

        it 'does not create the adjustment' do
          expect { subject.activate }.to_not(change { shipment.adjustments.count })
        end
      end

      context 'with a rule that has been satisfied' do
        let!(:promotion) do
          create(:promotion, :with_item_total_rule, apply_automatically: true,
                                                    promotion_actions: [action],
                                                    item_total_threshold_amount: order.item_total / 2)
        end

        it 'creates the adjustment' do
          expect { subject.activate }.to change { shipment.adjustments.count }.by(1)
        end
      end

      context 'with a code' do
        let!(:promotion) { create(:promotion, code: 'freeshipping', promotion_actions: [action]) }

        context 'when already applied' do
          before do
            order.order_promotions.create!(promotion: promotion, promotion_code: promotion.codes.first)
          end

          it 'adjusts the shipment' do
            expect {
              subject.activate
            }.to change { shipment.adjustments.count }
          end
        end

        context 'when not already applied' do
          it 'does not adjust the shipment' do
            expect {
              subject.activate
            }.to_not change { shipment.adjustments.count }
          end
        end
      end
    end
  end
end
