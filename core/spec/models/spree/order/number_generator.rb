require 'rails_helper'

RSpec.describe Spree::Order::NumberGenerator do
  subject(:generator) { described_class.new }

  describe '#generate' do
    context 'when is called on a depracated class' do
      it 'calls the method on the new class' do
        expect_any_instance_of(Spree::Core::NumberGenerator).to receive(:generate)
        generator.generate
      end
    end
  end
end
