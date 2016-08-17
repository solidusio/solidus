require 'spec_helper'

module Spree
  module PromotionHandler
    describe FreeShipping, type: :model do
      let(:order) { create(:order) }
      let(:shipment) { create(:shipment, order: order ) }

      let(:action) { Spree::Promotion::Actions::FreeShipping.new }

      subject { Spree::PromotionHandler::FreeShipping.new(order) }

      context 'with apply_automatically' do
        let!(:promotion) { create(:promotion, apply_automatically: true, promotion_actions: [action]) }

        it "creates the adjustment" do
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
