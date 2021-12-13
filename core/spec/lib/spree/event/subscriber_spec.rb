# frozen_string_literal: true

require 'rails_helper'
require 'active_support/all'
require 'spec_helper'
require 'spree/event'
require 'spree/event/adapters/deprecation_handler'
require 'spree/event/listener'

RSpec.describe Spree::Event::Subscriber do
  module M
    include Spree::Event::Subscriber

    event_action :event_name
    event_action :for_event_foo, event_name: :foo

    def event_name(event)
      # code that handles the event
    end

    def for_event_foo(event)
      # code that handles the event
    end

    def other_event(event)
      # not registered via event_action
    end
  end

  describe '::activate' do
    before { M.deactivate }

    it 'adds new listeners to Spree::Event' do
      expect { M.activate }.to change { Spree::Event.listeners }
    end

    context 'when subscriptions are not registered' do
      it 'does not trigger the event callback' do
        expect(M).not_to receive(:event_name)
        Spree::Event.fire 'event_name'
      end
    end

    it 'subscribes event actions' do
      M.activate
      expect(M).to receive(:event_name)
      Spree::Event.fire 'event_name'
    end

    it 'does not subscribe event actions more than once' do
      2.times { M.activate }
      expect(M).to receive(:event_name).once
      Spree::Event.fire 'event_name'
    end
  end

  describe '::deactivate' do
    before { M.activate }

    it 'removes the subscription' do
      expect(M).not_to receive(:event_name)
      M.deactivate
      Spree::Event.fire 'event_name'
    end
  end

  describe '::event_action' do
    context 'when the action has not been declared' do
      before { M.activate }

      it 'does not subscribe the action' do
        expect(M).not_to receive(:other_event)
        Spree::Event.fire 'other_event'
      end
    end

    context 'when the action is declared' do
      before do
        M.event_action :other_event
        M.activate
      end

      after do
        M.deactivate
        M.event_actions.delete(:other_event)
      end

      it 'subscribe the action' do
        expect(M).to receive(:other_event)
        Spree::Event.fire 'other_event'
      end
    end
  end

  unless Spree::Event::Adapters::DeprecationHandler.legacy_adapter?
    describe '::listeners' do
        before { M.activate }
        after { M.deactivate }

        it 'returns all listeners that the subscriber generates when no arguments are given', :aggregate_failures do
          listeners = M.listeners

          expect(listeners.count).to be(2)
          expect(listeners.first).to be_a(Spree::Event::Listener)
        end

        it 'can restrict by event names given as arguments', :aggregate_failures do
          listeners = M.listeners('event_name')

          expect(listeners.count).to be(1)
          expect(listeners.first.pattern).to eq('event_name')

          listeners = M.listeners('event_name', 'foo')

          expect(listeners.count).to be(2)
          expect(listeners.map(&:pattern)).to match(['event_name', 'foo'])
        end
    end
  end
end
