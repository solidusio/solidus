# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe MergeableOrdersFinder do
    let(:user) { create(:user) }
    let(:store) { create(:store) }
    let(:current_order) { create(:order, user: user, store: store) }
    let(:context) { double('context', spree_current_user: user, current_store: store, current_order: current_order) }
    let(:subject) { Spree::MergeableOrdersFinder.new(context: context) }

    describe '#call' do
      let!(:incomplete_order1) { create(:order, user: user, store: store, state: 'cart') }
      let!(:incomplete_order2) { create(:order, user: user, store: store, state: 'address') }
      let!(:complete_order) { create(:order, user: user, store: store, state: 'complete').touch(:completed_at) }
      let!(:other_store_order) { create(:order, user: user, state: 'cart') }

      it 'returns incomplete orders from the same store' do
        orders = subject.call
        expect(orders).to include(incomplete_order1, incomplete_order2)
        expect(orders).not_to include(current_order, complete_order, other_store_order)
      end

      context 'when user is nil' do
        let(:context) { double('context', spree_current_user: nil, current_store: store, current_order: current_order) }

        it 'returns empty relation' do
          orders = subject.call
          expect(orders).to be_empty
          expect(orders).to eq(Spree::Order.none)
        end
      end

      context 'when current_order is nil' do
        let(:context) { double('context', spree_current_user: user, current_store: store, current_order: nil) }

        it 'returns empty relation' do
          orders = subject.call
          expect(orders).to be_empty
          expect(orders).to eq(Spree::Order.none)
        end
      end

      context 'when both user and current_order are nil' do
        let(:context) { double('context', spree_current_user: nil, current_store: store, current_order: nil) }

        it 'returns empty relation' do
          orders = subject.call
          expect(orders).to be_empty
          expect(orders).to eq(Spree::Order.none)
        end
      end
    end
  end
end
