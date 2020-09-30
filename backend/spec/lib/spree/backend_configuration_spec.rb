# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::BackendConfiguration do
  describe '#menu_items' do
    subject do
      described_class.new.menu_items
    end

    describe 'menu tab for stock items' do
      let(:stock_menu_item) do
        subject.detect { |item| item.label == :stock }
      end

      # Regression for https://github.com/solidusio/solidus/issues/2950
      it 'has match_path set to /stock_items' do
        expect(stock_menu_item.match_path).to eq('/stock_items')
      end
    end

    describe 'menu tab for settings' do
      let(:menu_item) { subject.find { |item| item.label == :settings } }
      let(:view) { double("view") }

      it 'is shown if any of its submenus are present' do
        allow(view).to receive(:can?).and_return(true, false)

        result = view.instance_exec(&menu_item.condition)

        expect(result).to eq(true)
      end

      it 'is not shown if none of its submenus are present' do
        expect(view).to receive(:can?).exactly(12).times.and_return(false)

        result = view.instance_exec(&menu_item.condition)

        expect(result).to eq(false)
      end
    end
  end
end
