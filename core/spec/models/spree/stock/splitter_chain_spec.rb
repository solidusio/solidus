# frozen_string_literal: true

require 'rails_helper'

module Spree::Stock
  RSpec.describe SplitterChain, type: :model do
    let(:stock_location) { mock_model(Spree::StockLocation) }
    let(:splitter1) { Class.new(Splitter::Base) }
    let(:splitter2) { Class.new(Splitter::Base) }

    let(:package) { double(:package) }
    let(:packages) { [package] }

    subject { described_class.new(stock_location, splitters) }

    context 'with no splitters' do
      let(:splitters) { [] }

      it "returns the packages unchanged" do
        expect(subject.split(packages)).to eq packages
      end
    end

    context 'with one splitter' do
      let(:splitters) { [splitter1] }

      it 'returns the result form the splitter' do
        expected = double(:expected_packages)
        expect_any_instance_of(splitter1).to receive(:split).with(packages).and_return(expected)

        expect(subject.split(packages)).to be expected
      end

      it 'builds the splitters correctly' do
        expect(splitter1).to receive(:new).with(stock_location, nil).and_call_original

        subject.split(packages)
      end
    end

    context 'with multiple splitters' do
      let(:splitters) { [splitter1, splitter2] }

      it 'builds the splitters in order' do
        expect(splitter1).to receive(:new).with(stock_location, splitter2).and_call_original
        expect(splitter2).to receive(:new).with(stock_location, nil).and_call_original

        subject.split(packages)
      end

      it 'calls the splitters in order' do
        expect_any_instance_of(splitter1).to receive(:split).with(packages).and_call_original
        expect_any_instance_of(splitter2).to receive(:split).with(packages).and_call_original

        subject.split(packages)
      end

      it 'returns the final result' do
        expected = double(:expected_packages)
        expect_any_instance_of(splitter2).to receive(:split).with(packages).and_return(expected)

        expect(subject.split(packages)).to be expected
      end
    end
  end
end
