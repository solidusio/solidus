# frozen_string_literal: true

require 'spree/event/listener'
require 'spree/event/execution'

RSpec.describe Spree::Event::Listener do
  describe '#call' do
    it 'returns an execution instance' do
      listener = described_class.new(pattern: 'foo', block: proc {})

      expect(listener.call(:event)).to be_a(Spree::Event::Execution)
    end

    it "binds the event and sets execution's result" do
      listener = described_class.new(pattern: 'foo', block: ->(event) { event[:foo] })

      execution = listener.call(foo: :bar)

      expect(execution.result).to eq(:bar)
    end

    it 'sets itself as the execution listener' do
      listener = described_class.new(pattern: 'foo', block: proc { 'foo' })

      execution = listener.call(:event)

      expect(execution.listener).to be(listener)
    end

    it "sets the execution's benchmark" do
      listener = described_class.new(pattern: 'foo', block: proc { 'foo' })

      execution = listener.call(:event)

      expect(execution.benchmark).to be_a(Benchmark::Tms)
    end
  end

  describe '#matches?' do
    it 'return true when given event name matches pattern as a string' do
      listener = described_class.new(pattern: 'foo', block: -> {})

      expect(listener.matches?('foo')).to be(true)
    end

    it 'return true when given event name matches pattern as a regexp' do
      listener = described_class.new(pattern: /oo/, block: -> {})

      expect(listener.matches?('foo')).to be(true)
    end

    it "returns false when given event name doesn't match pattern" do
      listener = described_class.new(pattern: 'foo', block: -> {})

      expect(listener.matches?('bar')).to be(false)
    end

    it "returns false when given event name matches but the listener is unsubscribed from the event" do
      listener = described_class.new(pattern: 'foo', block: -> {})

      listener.unsubscribe('foo')

      expect(listener.matches?('foo')).to be(false)
    end
  end

  describe '#unsubscribe' do
    context 'when event name matches' do
      it "adds an exclusion so that it no longer matches" do
        listener = described_class.new(pattern: 'foo', block: -> {})

        expect(listener.matches?('foo')).to be(true)

        listener.unsubscribe('foo')

        expect(listener.matches?('foo')).to be(false)
      end
    end

    context "when event name doesn't match" do
      it 'does nothing' do
        listener = described_class.new(pattern: 'foo', block: -> {})

        listener.unsubscribe('bar')

        expect(listener.matches?('foo')).to be(true)
        expect(listener.matches?('bar')).to be(false)
      end
    end
  end

  describe '#listeners' do
    it 'returns a list containing only itself' do
      listener = described_class.new(pattern: 'foo', block: -> {})

      expect(listener.listeners).to eq([listener])
    end
  end
end
