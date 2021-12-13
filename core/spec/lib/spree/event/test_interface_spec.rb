# frozen_string_literal: true

require 'rails_helper'
require 'spree/event/adapters/deprecation_handler'
require 'spree/event/test_interface'

RSpec.describe Spree::Event::TestInterface do
  let(:counter) do
    Class.new do
      attr_reader :count

      def initialize
        @count = 0
      end

      def inc
        @count += 1
      end
    end
  end

  describe '#enable_test_interface' do
    context 'when using the legacy adapter' do
      it 'raises an error' do
        adapter = Spree::Config.events.adapter
        Spree::Config.events.adapter = Spree::Event::Adapters::ActiveSupportNotifications

        expect {
          Spree::Event.enable_test_interface
        }.to raise_error(/test interface is not supported/)
      ensure
        Spree::Config.events.adapter = adapter
      end
    end
  end

  unless Spree::Event::Adapters::DeprecationHandler.legacy_adapter?
    it 'can be accessed directly from TestInterface' do
      dummy = counter.new
      listener = Spree::Event.subscribe('foo') { dummy.inc }

      described_class.performing_only(listener) do
        Spree::Event.fire('foo')
      end

      expect(dummy.count).to be(1)
    end

    describe '#performing_only' do
      before { Spree::Event.enable_test_interface }

      it 'only performs given listeners for the duration of the block', :aggregate_failures do
        dummy1, dummy2, dummy3 = Array.new(3) { counter.new }
        listener1 = Spree::Event.subscribe('foo') { dummy1.inc }
        listener2 = Spree::Event.subscribe('foo') { dummy2.inc }
        listener3 = Spree::Event.subscribe('foo') { dummy3.inc }

        Spree::Event.performing_only(listener1, listener2) do
          Spree::Event.fire('foo')
        end

        expect(dummy1.count).to be(1)
        expect(dummy2.count).to be(1)
        expect(dummy3.count).to be(0)
      end

      it 'performs again all the listeners once the block is done', :aggregate_failures do
        dummy1, dummy2 = Array.new(2) { counter.new }
        listener1 = Spree::Event.subscribe('foo') { dummy1.inc }
        listener2 = Spree::Event.subscribe('foo') { dummy2.inc }

        Spree::Event.performing_only(listener1) do
          Spree::Event.fire('foo')
        end

        expect(dummy1.count).to be(1)
        expect(dummy2.count).to be(0)

        Spree::Event.fire('foo')

        expect(dummy2.count).to be(1)
      end

      it 'can extract listeners from a subscriber module', :aggregate_failures do
        dummy1, dummy2 = Array.new(2) { counter.new }
        Subscriber1 = Module.new do
          include Spree::Event::Subscriber

          event_action :foo

          def foo(event)
            event.payload[:dummy1].inc
          end
        end
        Subscriber2 = Module.new do
          include Spree::Event::Subscriber

          event_action :foo

          def foo(event)
            event.payload[:dummy2].inc
          end
        end
        Spree::Event.subscriber_registry.register(Subscriber1)
        Spree::Event.subscriber_registry.register(Subscriber2)
        [Subscriber1, Subscriber2].map(&:activate)

        Spree::Event.performing_only(Subscriber1) do
          Spree::Event.fire('foo', dummy1: dummy1, dummy2: dummy2)
        end

        expect(dummy1.count).to be(1)
        expect(dummy2.count).to be(0)
      ensure
        Spree::Event.subscriber_registry.deactivate_subscriber(Subscriber1)
        Spree::Event.subscriber_registry.deactivate_subscriber(Subscriber2)
      end

      it 'can mix listeners and array of listeners', :aggregate_failures do
        dummy1, dummy2 = Array.new(2) { counter.new }
        listener = Spree::Event.subscribe('foo') { dummy1.inc }
        Subscriber = Module.new do
          include Spree::Event::Subscriber

          event_action :foo

          def foo(event)
            event.payload[:dummy2].inc
          end
        end
        Spree::Event.subscriber_registry.register(Subscriber)
        Subscriber.activate

        Spree::Event.performing_only(listener, Subscriber) do
          Spree::Event.fire('foo', dummy2: dummy2)
        end

        expect(dummy1.count).to be(1)
        expect(dummy2.count).to be(1)
      ensure
        Spree::Event.subscriber_registry.deactivate_subscriber(Subscriber)
      end

      it 'can perform no listener at all' do
        dummy = counter.new
        listener = Spree::Event.subscribe('foo') { dummy.inc }

        Spree::Event.performing_only do
          Spree::Event.fire('foo')
        end

        expect(dummy.count).to be(0)
      end

      it 'can override through an inner call' do
        dummy = counter.new
        listener = Spree::Event.subscribe('foo') { dummy.inc }

        Spree::Event.performing_only do
          Spree::Event.performing_only(listener) do
            Spree::Event.fire('foo')
          end
        end

        expect(dummy.count).to be(1)
      end
    end

    describe '#performing_nothing' do
      before { Spree::Event.enable_test_interface }

      it 'performs no listener for the duration of the block' do
        dummy = counter.new
        listener = Spree::Event.subscribe('foo') { dummy.inc }

        Spree::Event.performing_nothing do
          Spree::Event.fire('foo')
        end

        expect(dummy.count).to be(0)
      end
    end
  end
end
