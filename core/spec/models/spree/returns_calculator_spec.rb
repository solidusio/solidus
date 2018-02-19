# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe ReturnsCalculator, type: :model do
    let(:return_item) { build(:return_item) }
    subject { ReturnsCalculator.new }

    it 'compute_shipment must be overridden' do
      expect {
        subject.compute(return_item)
      }.to raise_error NotImplementedError
    end
  end
end
