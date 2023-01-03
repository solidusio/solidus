# frozen_string_literal: true

require 'spec_helper'
require 'spree/testing_support/bus_helpers'

RSpec.describe Spree::TestingSupport::BusHelpers do
  include described_class

  describe '#stub_spree_bus' do
    it 'stubs `publish` method' do
      stub_spree_bus

      Spree::Bus.publish :foo

      expect(Spree::Bus).to have_received(:publish)
    end
  end

  describe '#have_been_published' do
    it "matches when the event has been published without payload and there's no expectation on it" do
      stub_spree_bus

      Spree::Bus.publish :foo

      expect(:foo).to have_been_published
    end

    it "matches when the event has been published with payload but there's no expectation on it" do
      stub_spree_bus

      Spree::Bus.publish :foo, bar: :baz

      expect(:foo).to have_been_published
    end

    it "matches when the event has been published with payload and the expectation on it matches" do
      stub_spree_bus

      Spree::Bus.publish :foo, bar: :baz

      expect(:foo).to have_been_published.with(bar: :baz)
    end

    it "can match payload with an inner matcher" do
      stub_spree_bus

      Spree::Bus.publish :foo, bar: :baz, tar: :tar

      expect(:foo).to have_been_published.with(a_hash_including(bar: :baz))
    end

    it "doesn't match when the event hasn't been published" do
      stub_spree_bus

      expect {
        expect(:foo).to have_been_published
      }.to raise_error /expected :foo to have been published/
    end

    it "doesn't match when the event has been published but the payload doesn't match" do
      stub_spree_bus

      Spree::Bus.publish :foo, foo: :bar

      expect {
        expect(:foo).to have_been_published.with(bar: :baz)
      }.to raise_error /Make sure that provided payload.*also matches/
    end

    it "raises when expected event is not a valid name" do
      expect {
        expect([]).to have_been_published.with(bar: :baz)
      }.to raise_error /not a valid event name/
    end
  end
end

