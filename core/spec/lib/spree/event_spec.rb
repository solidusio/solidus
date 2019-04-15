# frozen_string_literal: true

require 'spec_helper'
require 'spree/event'

RSpec.describe Spree::Event do
  let(:subscription_name) { 'foo_bar' }
  let(:item) { spy('object') }
  let(:notifier) { ActiveSupport::Notifications.notifier }

  subject { described_class }

  it 'has default adapter' do
    expect(subject.adapter).to eql Spree::Event::Adapters::ActiveSupportNotifications
  end

  before do
    # ActiveSupport::Notifications does not provide an interface to clean all
    # subscribers at once, so some low level brittle code is required
    @old_subscribers = notifier.instance_variable_get('@subscribers').dup
    @old_listeners = notifier.instance_variable_get('@listeners_for').dup
    notifier.instance_variable_get('@subscribers').clear
    notifier.instance_variable_get('@listeners_for').clear
  end

  after do
    notifier.instance_variable_set '@subscribers', @old_subscribers
    notifier.instance_variable_set '@listeners_for', @old_listeners
  end

  context 'with the default adapter' do
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
