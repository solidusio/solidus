# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::OrderCapturing do
  describe '#capture_payments' do
    subject { Solidus::OrderCapturing.new(order).capture_payments }

    let(:order) { build(:completed_order_with_totals) }

    it 'is deprecated' do
      expect(Solidus::Deprecation).to(receive(:warn))
      subject
    end
  end
end
