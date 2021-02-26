# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order::NumberGenerator do
  describe '#generate' do
    before do
      Spree::Deprecation.behavior = behavior
    end

    context 'when is called on a depracated class without raising' do
      let(:behavior) { :silence }

      it 'calls the method on the new class' do
        expect_any_instance_of(Spree::Core::NumberGenerator).to receive(:generate)
        described_class.new.generate
      end
    end

    context 'when is called on a depracated class with raising behavior' do
      let(:behavior) { :raise }

      it 'raises DeprecationException' do
        expect { described_class.new }.to raise_error(ActiveSupport::DeprecationException)
      end
    end
  end
end
