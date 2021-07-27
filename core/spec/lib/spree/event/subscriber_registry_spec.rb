# frozen_string_literal: true
require 'rails_helper'
require 'active_support/all'
require 'spec_helper'
require 'spree/event'
require 'spree/event/adapters/deprecation_handler'
require 'spree/event/listener'

RSpec.describe Spree::Event::SubscriberRegistry do
  module N
    include Spree::Event::Subscriber

    event_action :event_name
    event_action :other_event

    def event_name(event)
      # code that handles the event
    end

    def other_event(event)
      # code that handles the event
    end
  end

  describe "#activate_all_subscribers" do
    before { subject.register(N) }

    it "delegates to #activate_subscriber for each registered subscriber" do
      expect(subject).to receive(:activate_subscriber).with(N)

      subject.activate_all_subscribers
    end
  end

  describe "#deactivate_all_subscribers" do
    before { subject.register(N) }

    it "delegates to #deactivate_subscriber for each registered subscriber" do
      expect(subject).to receive(:deactivate_subscriber).with(N)

      subject.deactivate_all_subscribers
    end
  end

  describe "#activate_subscriber" do
    before do
      N.deactivate
      Spree::Event.subscriber_registry.send(:registry).delete("N")
    end

    context "with an unregistered subscriber" do
      it "does not activate the subscriber" do
        expect(N).not_to receive(:event_name)

        subject.activate_subscriber(N)
        Spree::Event.fire(:event_name)
      end
    end

    context "with a registered subscriber" do
      before { subject.register(N) }

      it "activates the subscriber" do
        expect(N).to receive(:event_name)

        subject.activate_subscriber(N)
        Spree::Event.fire(:event_name)
      end

      after { subject.deactivate_subscriber(N) }
    end
  end

  describe "#deactivate_subscriber" do
    context "with a unregistered subscriber" do
      before do
        N.deactivate
        Spree::Event.subscriber_registry.send(:registry).delete("N")
      end

      it { expect { subject.deactivate_subscriber(N) }.not_to raise_error }
    end

    context "with a registered subscriber" do
      before { subject.register(N) }

      after { subject.deactivate_subscriber(N) }

      context "with the module was activated" do
        before { subject.activate_subscriber(N) }

        context "when deactivating the whole module" do
          it "removes all the module event callbacks" do
            expect(N).not_to receive(:event_name)
            expect(N).not_to receive(:other_event)

            subject.deactivate_subscriber(N)
            Spree::Event.fire(:event_name)
            Spree::Event.fire(:other_event)
          end
        end

        context "when unsubscribing a single event action" do
          context "when deactivating a single event action" do
            it "removes the single event action callbacks" do
              expect(N).not_to receive(:event_name)
              expect(N).to receive(:other_event)

              subject.deactivate_subscriber(N, :event_name)
              Spree::Event.fire(:event_name)
              Spree::Event.fire(:other_event)
            end
          end
        end
      end
    end
  end

  describe '#listeners' do
    if Spree::Event::Adapters::DeprecationHandler.legacy_adapter?
      it 'raises error' do
        expect { subject.listeners(N) }.to raise_error /only available with the new adapter/
      end
    else
      before do
        subject.register(N)
        subject.activate_subscriber(N)
      end
      after { subject.deactivate_subscriber(N) }

      it 'returns all listeners that the subscriber generates', :aggregate_failures do
        listeners = subject.listeners(N)

        expect(listeners.count).to be(2)
        expect(listeners).to all be_a(Spree::Event::Listener)
      end

      it 'can restrict by event names', :aggregate_failures do
        listeners = subject.listeners(N, event_names: ['event_name'])

        expect(listeners.count).to be(1)
        expect(listeners.first.pattern).to eq('event_name')

        listeners = subject.listeners(N, event_names: ['event_name', 'other_event'])

        expect(listeners.count).to be(2)
        expect(listeners.map(&:pattern)).to match(['event_name', 'other_event'])
      end

      it 'can event names as symbols', :aggregate_failures do
        listeners = subject.listeners(N, event_names: [:event_name])

        expect(listeners.count).to be(1)
        expect(listeners.first.pattern).to eq('event_name')
      end
    end
  end
end
