# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::BackendConfiguration::MenuItem do
  describe '#match_path' do
    subject do
      described_class.new([], nil, {
        match_path: '/stock_items'
      }).match_path
    end

    it 'can be read' do
      is_expected.to eq('/stock_items')
    end
  end
end
