# frozen_string_literal: true

require 'rails_helper'
require 'spree/event/adapters/default'
require 'spree/event/adapters/active_support_notifications'

RSpec.describe Spree::Event do
  subject { described_class }

  def build_bus
    Spree::Event::Adapters::Default.new
  end

  describe '.default_adapter' do
    it 'returns configured adapter' do
      expect(subject.default_adapter).to be_an_instance_of Spree::Event::Adapters::Default
    end
  end

  describe '.fire' do
    it 'forwards to adapter' do
      bus = build_bus
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      subject.subscribe('foo', adapter: bus) { dummy.toggle }

      subject.fire 'foo', adapter: bus

      expect(dummy.run).to be(true)
    end

    it 'coerces event names given as symbols' do
      bus = build_bus
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      subject.subscribe('foo', adapter: bus) { dummy.toggle }

      subject.fire :foo, adapter: bus

      expect(dummy.run).to be(true)
    end

    it 'raises error if a block is given and the adapter is not ActiveSupportNotifications' do
      expect do
        subject.fire :foo, adapter: build_bus do
          1 + 1
        end
      end.to raise_error(ArgumentError, /Blocks.*are ignored/)
    end

    it 'renders a deprecation warning if a block is given and the adapter is ActiveSupportNotifications but still executes it' do
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new

      expect(Spree::Deprecation).to receive(:warn).with(/Blocks.*are ignored/)

      subject.fire(:foo, adapter: Spree::Event::Adapters::ActiveSupportNotifications) { dummy.toggle }

      expect(dummy.run).to be(true)
    end
  end

  describe '.subscribe' do
    it 'forwards to adapter' do
      bus = build_bus

      listener = subject.subscribe('foo', adapter: bus) {}

      expect(subject.listeners(adapter: bus)['foo'].first).to be(listener)
    end

    it 'coerces event names given as symbols' do
      bus = build_bus

      listener = subject.subscribe(:foo, adapter: bus) {}

      expect(subject.listeners(adapter: bus)['foo'].first).to be(listener)
    end
  end

  describe '#unsubscribe' do
    it 'delegates to the adapter' do
      bus = build_bus
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      listener = subject.subscribe('foo', adapter: bus) { dummy.toggle }

      subject.unsubscribe listener, adapter: bus
      subject.fire 'foo', adapter: bus

      expect(dummy.run).to be(false)
    end

    it 'coerces event names given as symbols' do
      bus = build_bus
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      subject.subscribe('foo', adapter: bus) { dummy.toggle }

      subject.unsubscribe :foo, adapter: bus
      subject.fire 'foo', adapter: bus

      expect(dummy.run).to be(false)
    end
  end

  describe '#listeners' do
    it 'returns mapping of all listeners by event name' do
      bus = build_bus
      listener_foo = subject.subscribe('foo', adapter: bus) {}
      listener_bar = subject.subscribe('bar', adapter: bus) {}

      listeners = subject.listeners(adapter: bus)

      expect(listeners).to match(
        "foo" => [listener_foo],
        "bar" => [listener_bar]
      )
    end
  end

  context 'with the default adapter' do
    let(:item) { spy('object') }
    let(:subscription_name) { 'foo_bar' }
    let(:notifier) { ActiveSupport::Notifications.notifier }

    before do
      @adapter = Spree::Config.events.adapter
      Spree::Config.events.adapter = Spree::Event::Adapters::ActiveSupportNotifications
      # ActiveSupport::Notifications does not provide an interface to clean all
      # subscribers at once, so some low level brittle code is required
      if Rails.gem_version >= Gem::Version.new('6.0.0')
        @old_string_subscribers = notifier.instance_variable_get('@string_subscribers').dup
        @old_other_subscribers = notifier.instance_variable_get('@other_subscribers').dup
        notifier.instance_variable_get('@string_subscribers').clear
        notifier.instance_variable_get('@other_subscribers').clear
      else
        @old_subscribers = notifier.instance_variable_get('@subscribers').dup
        notifier.instance_variable_get('@subscribers').clear
      end
      @old_listeners = notifier.instance_variable_get('@listeners_for').dup
      notifier.instance_variable_get('@listeners_for').clear
    end

    after do
      if Rails.gem_version >= Gem::Version.new('6.0.0')
        notifier.instance_variable_set '@string_subscribers', @old_string_subscribers
        notifier.instance_variable_set '@other_subscribers', @old_other_subscribers
      else
        notifier.instance_variable_set '@subscribers', @old_subscribers
      end
      notifier.instance_variable_set '@listeners_for', @old_listeners
      Spree::Config.events.adapter = @adapter
    end

    describe '#listeners' do
      context 'when there is no subscription' do
        it { expect(subject.listeners).to be_empty }

        context 'after adding a subscription' do
          before do
            Spree::Event.subscribe(subscription_name) { item.do_something }
          end

          it 'includes the new subscription with custom suffix' do
            expect(subject.listeners).to be_present
            subscription_listeners = subject.listeners["#{subscription_name}.spree"]
            expect(subscription_listeners).to be_a Array
            expect(subscription_listeners.first).to be_a ActiveSupport::Notifications::Fanout::Subscribers::Timed
          end
        end
      end
    end

    context 'subscriptions' do
      describe '#subscribe' do
        it 'can subscribe to events' do
          Spree::Event.subscribe(subscription_name) { item.do_something }
          Spree::Event.fire subscription_name
          expect(item).to have_received :do_something
        end

        it 'can subscribe to multiple events using a regexp' do
          Spree::Event.subscribe(/.*\.spree$/) { item.do_something_else }
          Spree::Event.fire subscription_name
          Spree::Event.fire 'another_event'
          expect(item).to have_received(:do_something_else).twice
        end
      end

      describe '#unsubscribe' do
        context 'when unsubscribing using a subscription object as reference' do
          let!(:subscription) { Spree::Event.subscribe(subscription_name) { item.do_something } }

          before do
            Spree::Event.subscribe(subscription_name) { item.do_something_else }
          end

          it 'can unsubscribe from single event by object' do
            subject.unsubscribe subscription
            Spree::Event.fire subscription_name
            expect(item).not_to have_received :do_something
            expect(item).to have_received :do_something_else
          end
        end

        context 'when unsubscribing using a string as reference' do
          before do
            Spree::Event.subscribe(subscription_name) { item.do_something }
            Spree::Event.subscribe(subscription_name) { item.do_something_else }
          end

          it 'can unsubscribe from multiple events with the same name' do
            subject.unsubscribe subscription_name
            Spree::Event.fire subscription_name
            expect(item).not_to have_received :do_something
            expect(item).not_to have_received :do_something_else
          end
        end
      end
    end
  end
end
