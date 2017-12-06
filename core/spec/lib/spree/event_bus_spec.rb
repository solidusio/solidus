# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::EventBus do
  class SomeEventClass; end
  let(:event_bus) { Spree::EventBus.instance }
  let(:event_class) { SomeEventClass }
  let(:subscriber) { ->(_data) {} }

  before(:each) do
    event_bus.clear_subscribers(event_class)
  end

  describe '#subscribe' do
    subject { event_bus.subscribe(event_class, subscriber) }

    it 'subscribes once' do
      4.times { subject }
      expect(event_bus.subscriber_count(event_class)).to eq(1)
    end
  end

  describe '#publish' do
    subject { event_bus.publish(event_instance) }
    let(:event_instance) { SomeEventClass.new }

    it 'does not error with no subscribers' do
      expect{ subject }.not_to raise_error
    end

    context 'there are subscribers' do
      before { event_bus.subscribe(event_class, subscriber) }

      it 'calls subscriber with event data' do
        expect(subscriber).to receive(:call).with(event_instance)
        subject
      end
    end
  end
end
