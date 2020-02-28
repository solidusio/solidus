# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Event do
  let(:subscription_name) { 'foo_bar' }
  let(:item) { spy('object') }
  let(:notifier) { ActiveSupport::Notifications.notifier }

  subject { described_class }

  it 'has default adapter' do
    expect(subject.adapter).to eql Spree::Event::Adapters::ActiveSupportNotifications
  end

  context 'with the default adapter' do
    before do
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

  describe '.subscribers' do
    let(:subscriber) { instance_double(Module, 'Subscriber') }
    let(:subscriber_name) { instance_double(String, 'Subscriber name') }

    before do
      described_class.subscribers.clear
      allow(subscriber).to receive(:name).and_return(subscriber_name)
      allow(subscriber_name).to receive(:constantize).and_return(subscriber)
      allow(subscriber_name).to receive(:to_s).and_return(subscriber_name)
    end

    it 'accepts the names of constants' do
      Spree::Config.events.subscribers << subscriber_name

      expect(described_class.subscribers.to_a).to eq([subscriber])
    end

    it 'discards duplicates' do
      described_class.subscribers << subscriber_name
      described_class.subscribers << subscriber_name
      described_class.subscribers << subscriber_name

      expect(described_class.subscribers.to_a).to eq([subscriber])
    end
  end
end
