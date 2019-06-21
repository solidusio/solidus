# frozen_string_literal: true

require 'spec_helper'
require 'spree/event'

RSpec.describe Spree::Event::Subscriber do
  module M
    include Spree::Event::Subscriber

    event_action :event_name

    def event_name(event)
      # code that handles the event
    end

    def other_event(event)
      # ...
    end
  end

  describe '::subscribe!' do
    before { M.unsubscribe! }

    it 'adds new listeners to Spree::Event' do
      expect { M.subscribe! }.to change { Spree::Event.listeners }
    end

    context 'when subscriptions are not registered' do
      it 'does not trigger the event callback' do
        expect(M).not_to receive(:event_name)
        Spree::Event.fire 'event_name'
      end
    end

    it 'subscribes event actions' do
      M.subscribe!
      expect(M).to receive(:event_name)
      Spree::Event.fire 'event_name'
    end

    it 'does not subscribe event actions more than once' do
      2.times { M.subscribe! }
      expect(M).to receive(:event_name).once
      Spree::Event.fire 'event_name'
    end
  end

  describe '::unsubscribe' do
    before { M.subscribe! }

    it 'removes the subscription' do
      expect(M).not_to receive(:event_name)
      M.unsubscribe!
      Spree::Event.fire 'event_name'
    end
  end

  describe '::event_action' do
    context 'when the action has not been declared' do
      before { M.subscribe! }

      it 'does not subscribe the action' do
        expect(M).not_to receive(:other_event)
        Spree::Event.fire 'other_event'
      end
    end

    context 'when the action is declared' do
      before do
        M.event_action :other_event
        M.subscribe!
      end

      after do
        M.unsubscribe!
        M.event_actions.delete(:other_event)
      end

      it 'subscribe the action' do
        expect(M).to receive(:other_event)
        Spree::Event.fire 'other_event'
      end
    end
  end
end
