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
  end
end
