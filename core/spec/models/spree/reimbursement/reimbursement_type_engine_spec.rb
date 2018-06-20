# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe Reimbursement::ReimbursementTypeEngine, type: :model do
    describe '#calculate_reimbursement_types' do
      let(:reimbursement_type_engine) { Spree::Reimbursement::ReimbursementTypeEngine.new(reimbursement) }
      let(:original_payment) { Spree::ReimbursementType::OriginalPayment.new }
      let(:store_credit) { Spree::ReimbursementType::StoreCredit.new }
      let(:exchange) { Spree::ReimbursementType::Exchange.new }
      let(:calculated_reimbursement_types) { subject }
      let(:all_reimbursement_types) {
        [
          original_payment,
          store_credit,
          exchange
        ]
      }

      subject { reimbursement_type_engine.calculate_reimbursement_types }

      shared_examples_for "reimbursement type hash" do
        it "contain all keys that respond to reimburse" do
          calculated_reimbursement_types.keys.each do |r_type|
            expect(r_type).to respond_to :reimburse
          end
        end
      end

      context 'the reimbursement does not contain a settlement' do
        let(:return_item)     { create(:return_item, acceptance_status: 'accepted') }
        let(:return_items)    { [return_item] }
        let(:customer_return) { build(:customer_return, return_items: return_items) }
        let(:reimbursement)   { create(:reimbursement, customer_return: customer_return, return_items: return_items) }

        before do
          reimbursement_type_engine.expired_reimbursement_type = exchange.class
          allow(return_item.inventory_unit.shipment).to receive(:shipped_at).and_return(Date.yesterday)
          allow(return_item).to receive(:exchange_required?).and_return(false)
        end

        context 'the return item requires exchange' do
          before { allow(return_item).to receive(:exchange_required?).and_return(true) }

          it 'returns a hash with the exchange reimbursement type associated to the return items' do
            expect(calculated_reimbursement_types[reimbursement_type_engine.exchange_reimbursement_type]).to eq([return_item])
          end

          it 'the return items are not included in any of the other reimbursement types' do
            (all_reimbursement_types - [reimbursement_type_engine.exchange_reimbursement_type]).each do |r_type|
              expect(calculated_reimbursement_types[r_type]).to eq([])
            end
          end

          it_should_behave_like 'reimbursement type hash'
        end

        context 'the return item does not require exchange' do
          context 'the return item has an override reimbursement type' do
            before { allow(return_item).to receive(:override_reimbursement_type).and_return(store_credit) }

            it 'returns a hash with the override reimbursement type associated to the return items' do
              expect(calculated_reimbursement_types[store_credit.class]).to eq(return_items)
            end

            it 'the return items are not included in any of the other reimbursement types' do
              (all_reimbursement_types - [store_credit.class]).each do |r_type|
                expect(calculated_reimbursement_types[r_type]).to eq([])
              end
            end

            it_should_behave_like 'reimbursement type hash'
          end

          context 'the return item does not have an override reimbursement type' do
            context 'the return item has a preferred reimbursement type' do
              before { allow(return_item).to receive(:preferred_reimbursement_type).and_return(store_credit) }

              context 'the reimbursement type is not valid for the return item' do
                before { expect(reimbursement_type_engine).to receive(:valid_preferred_reimbursement_type?).and_return(false) }

                it 'returns a hash with no return items associated to the preferred reimbursement type' do
                  expect(calculated_reimbursement_types[store_credit.class]).to eq([])
                end

                it 'the return items are not included in any of the other reimbursement types' do
                  (all_reimbursement_types - [store_credit.class]).each do |r_type|
                    expect(calculated_reimbursement_types[r_type]).to eq([])
                  end
                end

                it_should_behave_like 'reimbursement type hash'
              end

              context 'the reimbursement type is valid for the return item' do
                it 'returns a hash with the expired reimbursement type associated to the return items' do
                  expect(calculated_reimbursement_types[store_credit.class]).to eq(return_items)
                end

                it 'the return items are not included in any of the other reimbursement types' do
                  (all_reimbursement_types - [store_credit.class]).each do |r_type|
                    expect(calculated_reimbursement_types[r_type]).to eq([])
                  end
                end

                it_should_behave_like 'reimbursement type hash'
              end
            end

            context 'the return item does not have a preferred reimbursement type' do
              context 'the return item is past the time constraint' do
                before { allow(reimbursement_type_engine).to receive(:past_reimbursable_time_period?).and_return(true) }

                it 'returns a hash with the expired reimbursement type associated to the return items' do
                  expect(calculated_reimbursement_types[exchange.class]).to eq(return_items)
                end

                it 'the return items are not included in any of the other reimbursement types' do
                  (all_reimbursement_types - [exchange.class]).each do |r_type|
                    expect(calculated_reimbursement_types[r_type]).to eq([])
                  end
                end

                it_should_behave_like 'reimbursement type hash'
              end

              context 'the return item is within the time constraint' do
                it 'returns a hash with the default reimbursement type associated to the return items' do
                  expect(calculated_reimbursement_types[reimbursement_type_engine.default_reimbursement_type]).to eq(return_items)
                end

                it 'the return items are not included in any of the other reimbursement types' do
                  (all_reimbursement_types - [reimbursement_type_engine.default_reimbursement_type]).each do |r_type|
                    expect(calculated_reimbursement_types[r_type]).to eq([])
                  end
                end

                it_should_behave_like 'reimbursement type hash'
              end
            end
          end
        end
      end

      context 'the reimbursement contains a settlement' do
        let(:return_item) { create(:return_item, acceptance_status: 'accepted') }
        let(:return_items)    { [return_item] }
        let(:customer_return) { build(:customer_return, return_items: return_items) }
        let(:settlement) { create(:settlement) }
        let(:reimbursement) { create(:reimbursement, customer_return: customer_return, return_items: return_items, settlements: [settlement]) }

        context 'the settlement is accepted' do
          before do
            settlement.acceptance_status = 'accepted'
          end

          context 'the settlement has a reimbursement_type' do
            before { allow_any_instance_of(Spree::Settlement).to receive(:reimbursement_type).and_return(store_credit) }

            it 'returns a hash with the reimbursement type associated to the settlement' do
              expect(calculated_reimbursement_types[store_credit.class]).to include(settlement)
            end

            it 'the settlement is not included in any of the other reimbursement types' do
              (all_reimbursement_types - [store_credit.class]).each do |r_type|
                expect(calculated_reimbursement_types[r_type]).not_to include(settlement)
              end
            end
          end

          context 'the settlement does not have a reimbursement_type' do
            it 'returns a hash with the default reimbursement type associated to the settlement' do
              expect(calculated_reimbursement_types[reimbursement_type_engine.default_reimbursement_type]).to include(settlement)
            end

            it 'the settlement is not included in any of the other reimbursement types' do
              (all_reimbursement_types - [reimbursement_type_engine.default_reimbursement_type]).each do |r_type|
                expect(calculated_reimbursement_types[r_type]).not_to include(settlement)
              end
            end
          end

          context 'the settlement has an invalid reimbursement_type' do
            before { allow_any_instance_of(Spree::Settlement).to receive(:reimbursement_type).and_return(exchange) }

            it 'the settlement is not included in any of the reimbursement types' do
              all_reimbursement_types.each do |r_type|
                expect(calculated_reimbursement_types[r_type]).not_to include(settlement)
              end
            end
          end
        end

        context 'the settlement is rejected' do
          before do
            settlement.acceptance_status = 'rejected'
          end

          it 'the settlement is not included in any of the reimbursement types' do
            all_reimbursement_types.each do |r_type|
              expect(calculated_reimbursement_types[r_type]).not_to include(settlement)
            end
          end
        end
      end
    end
  end
end
