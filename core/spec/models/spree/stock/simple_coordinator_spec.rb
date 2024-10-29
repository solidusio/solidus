# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe SimpleCoordinator, type: :model do
      let(:order) { create(:order_with_line_items, line_items_count: 2) }

      subject { SimpleCoordinator.new(order) }

      describe "#shipments" do
        it 'uses the pluggable estimator class' do
          expect(Spree::Config.stock.estimator_class).to receive(:new).with(coordinator_options: {}).and_call_original

          subject.shipments
        end

        it 'uses the configured stock location filter' do
          expect(Spree::Config.stock.location_filter_class).to receive(:new).with(anything, anything, coordinator_options: {}).and_call_original

          subject.shipments
        end

        it 'uses the configured stock location sorter' do
          expect(Spree::Config.stock.location_sorter_class).to receive(:new).with(anything, coordinator_options: {}).and_call_original

          subject.shipments
        end

        it 'uses the pluggable allocator class' do
          expect(Spree::Config.stock.allocator_class).to receive(:new).with(anything, coordinator_options: {}).and_call_original

          subject.shipments
        end

        it 'uses the pluggable inventory unit builder class' do
          expect(Spree::Config.stock.inventory_unit_builder_class).to receive(:new).with(anything, coordinator_options: {}).and_call_original

          subject.shipments
        end
      end
    end
  end
end
