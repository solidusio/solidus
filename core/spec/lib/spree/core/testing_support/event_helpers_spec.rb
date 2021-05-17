# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/event_helpers'

RSpec.describe Spree::TestingSupport::EventHelpers do
  include described_class

  around do |example|
    module TestSubscriber1
      include ::Spree::Event::Subscriber

      event_action :handle_event, event_name: 'test_event'
      mattr_accessor :event_handled

      def handle_event(_event)
        self.event_handled = true
      end
    end

    module TestSubscriber2
      include ::Spree::Event::Subscriber

      event_action :handle_event, event_name: 'test_event'
      mattr_accessor :event_handled

      def handle_event(_event)
        self.event_handled = true
      end
    end

    example.call
  ensure
    Object.send(:remove_const, :TestSubscriber1)
    Object.send(:remove_const, :TestSubscriber2)
  end

  describe '#perform_subscribers' do
    context 'when :only is passed' do
      it 'runs the given code with the arguments only' do
        perform_subscribers(only: [TestSubscriber1]) do
          Spree::Event.fire('test_event')
        end

        expect(TestSubscriber1.event_handled).to eq(true)
        expect(TestSubscriber2.event_handled).to eq(nil)
      end
    end

    context 'when :except is passed' do
      it 'runs the given code with all subscribers except the arguments' do
        perform_subscribers(except: [TestSubscriber1]) do
          Spree::Event.fire('test_event')
        end

        expect(TestSubscriber1.event_handled).to eq(nil)
        expect(TestSubscriber2.event_handled).to eq(true)
      end
    end

    context 'when neither :only nor :except are passed' do
      it 'runs the given code with all subscribers' do
        perform_subscribers do
          Spree::Event.fire('test_event')
        end

        expect(TestSubscriber1.event_handled).to eq(true)
        expect(TestSubscriber2.event_handled).to eq(true)
      end
    end
  end
end
