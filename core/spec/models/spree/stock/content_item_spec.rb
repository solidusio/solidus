# frozen_string_literal: true

require 'rails_helper'

module Spree
  module Stock
    RSpec.describe ContentItem, type: :model do
      let(:instance) { ContentItem.new(inventory_unit, state) }
      let(:inventory_unit) { build(:inventory_unit) }
      let(:state) { :on_hand }

      describe '#variant' do
        subject { instance.variant }
        it { is_expected.to eq(inventory_unit.variant) }
      end

      describe '#weight' do
        subject { instance.weight }
        it { is_expected.to eq(0.to_d) }
      end

      describe '#line_item' do
        subject { instance.line_item }
        it { is_expected.to eq(inventory_unit.line_item) }
      end

      describe '#on_hand?' do
        subject { instance.on_hand? }

        context 'the state is on hand' do
          it { is_expected.to eq(true) }
        end

        context 'the state is not on hand' do
          let(:state) { 'foo' }
          it { is_expected.to eq(false) }
        end
      end

      describe '#backordered?' do
        subject { instance.backordered? }

        context 'the state is not backordered' do
          let(:state) { 'foo' }
          it { is_expected.to eq(false) }
        end

        context 'the state is backordered' do
          let(:state) { :backordered }
          it { is_expected.to eq(true) }
        end
      end

      describe '#price' do
        subject { instance.price }
        it { is_expected.to eq(10.to_d) }
      end

      describe '#amount' do
        subject { instance.amount }
        it { is_expected.to eq(10.to_d) }
      end

      describe '#quantity' do
        subject { instance.quantity }
        it { is_expected.to eq(1) }
      end
    end
  end
end
