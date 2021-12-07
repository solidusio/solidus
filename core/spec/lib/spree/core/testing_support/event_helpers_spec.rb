# frozen_string_literal: true

require 'spec_helper'
require 'spree/testing_support/event_helpers'

RSpec.describe Spree::TestingSupport::EventHelpers do
  include described_class

  describe '#stub_spree_events' do
    it 'creates a spy class from Spree::Event and assigns to itself' do
      stub_spree_events

      expect(Spree::Event.inspect).to include('ClassDouble')

      Spree::Event.fire 'foo'

      expect(Spree::Event).to have_received(:fire)
    end
  end

  describe '#have_been_fired' do
    it "matches when the event has been fired without payload and there's no expectation on it" do
      stub_spree_events

      Spree::Event.fire 'foo'

      expect('foo').to have_been_fired
    end

    it "matches when the event has been fired with payload but there's no expectation on it" do
      stub_spree_events

      Spree::Event.fire 'foo', bar: :baz

      expect('foo').to have_been_fired
    end

    it "matches when the event has been fired with payload and the expectation on it matches" do
      stub_spree_events

      Spree::Event.fire 'foo', bar: :baz

      expect('foo').to have_been_fired.with(bar: :baz)
    end

    it "matches when fired as string and matched as string" do
      stub_spree_events

      Spree::Event.fire 'foo'

      expect('foo').to have_been_fired
    end

    it "matches when fired as string but matched as symbol" do
      stub_spree_events

      Spree::Event.fire 'foo'

      expect(:foo).to have_been_fired
    end

    it "matches when fired as symbol but matched as string" do
      stub_spree_events

      Spree::Event.fire :foo

      expect('foo').to have_been_fired
    end

    it "matches when fired as symbol and matched as symbol" do
      stub_spree_events

      Spree::Event.fire :foo

      expect(:foo).to have_been_fired
    end

    it "can match payload with an inner matcher" do
      stub_spree_events

      Spree::Event.fire 'foo', bar: :baz, tar: :tar

      expect('foo').to have_been_fired.with(a_hash_including(bar: :baz))
    end

    it "doesn't match when the event hasn't been fired" do
      stub_spree_events

      expect {
        expect('foo').to have_been_fired
      }.to raise_error /expected "foo" to have been fired/
    end

    it "doesn't match when the event has been fired but the payload doesn't match" do
      stub_spree_events

      Spree::Event.fire 'foo', foo: :bar

      expect {
        expect('foo').to have_been_fired.with(bar: :baz)
      }.to raise_error /Make sure that provided payload.*also matches/
    end

    it "raises when expected event is not a valid name" do
      expect {
        expect([]).to have_been_fired.with(bar: :baz)
      }.to raise_error /not a valid event name/
    end
  end
end
