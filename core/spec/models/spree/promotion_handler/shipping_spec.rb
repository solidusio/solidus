# frozen_string_literal: true

require 'rails_helper'

module Spree
  module PromotionHandler
    RSpec.describe Shipping, type: :model do
      let(:order) { create(:order) }
      let(:shipment) { create(:shipment, order: order ) }

      let(:action) { Spree::Promotion::Actions::FreeShipping.new }

      subject { Spree::PromotionHandler::Shipping.new(order) }

      context 'with apply_automatically' do
        let!(:promotion) { create(:promotion, apply_automatically: true, promotion_actions: [action]) }

        context 'for eligible promotion' do
          it "creates the adjustment" do
            expect { subject.activate }.to change { shipment.adjustments.count }.by(1)
          end
        end

        context 'for ineligible promotion' do
          let!(:promotion) do
            create(:promotion, :with_item_total_rule, item_total_threshold_amount: 1_000, apply_automatically: true, promotion_actions: [action])
          end

          it "does not create the adjustment" do
            expect { subject.activate }.to change { shipment.adjustments.count }.by(0)
          end
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

          context 'when currently ineligible' do
            let(:promotion) do
              create(:promotion, :with_item_total_rule, item_total_threshold_amount: 1_000, code: 'freeshipping', promotion_actions: [action])
            end

            before do
              order.order_promotions.create!(promotion: promotion, promotion_code: promotion.codes.first)
            end

            it 'does not adjust the shipment' do
              expect {
                subject.activate
              }.to_not change { shipment.adjustments.count }
            end
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

      context 'with a custom shipping action' do
        before do
          stub_const('CustomShippingAction', custom_klass)

          allow(Spree::Config.environment.promotions).to receive(:shipping_actions) { ['CustomShippingAction'] }

          order.order_promotions.create!(promotion: promotion, promotion_code: promotion.codes.first)
        end

        let(:action) { custom_klass.new }
        let(:custom_klass) { Class.new(Spree::Promotion::Actions::FreeShipping) }
        let(:promotion) { create(:promotion, code: 'customshipping', promotion_actions: [action]) }

        it 'adjusts the shipment' do
          expect {
            subject.activate
          }.to change { shipment.adjustments.count }
        end
      end
    end
  end
end
