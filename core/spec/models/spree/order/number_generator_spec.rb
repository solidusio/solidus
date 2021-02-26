# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order::NumberGenerator do
  describe '#generate' do
    context 'when is called on a depracated class with raising behavior' do
      it 'raises DeprecationException' do
        expect { described_class.new }.to raise_error(ActiveSupport::DeprecationException)
      end
    end
  end
end
