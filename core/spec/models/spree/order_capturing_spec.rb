# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OrderCapturing do
  describe '#capture_payments' do
    subject { Spree::OrderCapturing.new(order).capture_payments }

    let(:order) { build(:completed_order_with_totals) }

    it 'is deprecated' do
      allow(Spree::Deprecation).to receive(:warn)
      expect(Spree::Deprecation).to receive(:warn).with(/Spree::OrderCapturing/, any_args)

      subject
    end
  end
end
