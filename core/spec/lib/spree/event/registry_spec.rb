# frozen_string_literal: true

require 'spree/event/registry'

RSpec.describe Spree::Event::Registry do
  describe '#register' do
    it 'adds given event name to the registry' do
      registry = described_class.new

      registry.register('foo')

      expect(registry.registered?('foo')).to be(true)
    end

    it 'adds given caller location to the registration' do
      registry = described_class.new

      registry.register('foo', caller_location: caller_locations(0)[0])

      expect(registry.registration('foo').caller_location.to_s).to include(__FILE__)
    end

    it 'raises with the registration location info when the event has already been registered' do
      registry = described_class.new

      registry.register('foo', caller_location: caller_locations(0)[0])

      expect {
        registry.register('foo', caller_location: caller_locations(2)[0])
      }.to raise_error(/already registered.*#{__FILE__}/m)
    end
  end

  describe '#unregister' do
    it 'removes given event name from the registry' do
      registry = described_class.new
      registry.register('foo')

      registry.unregister('foo')

      expect(registry.registered?('foo')).to be(false)
    end

    it "raises when the event hasn't been registered" do
      registry = described_class.new
      registry.register('bar')

      expect {
        registry.unregister('foo')
      }.to raise_error(/not registered.*bar/m)
    end
  end

  describe '#registration' do
    it 'finds the registration from given name' do
      registry = described_class.new

      registry.register('foo')

      expect(registry.registration('foo').event_name).to eq('foo')
    end

    it 'returns nil when the event name is not found' do
      registry = described_class.new

      expect(registry.registration('foo')).to be_nil
    end
  end

  describe '#registered?' do
    it 'returns true when given event name is registered' do
      registry = described_class.new
      registry.register('foo')

      expect(registry.registered?('foo')).to be(true)
    end

    it 'returns false when given event name is not registered' do
      registry = described_class.new

      expect(registry.registered?('foo')).to be(false)
    end
  end

  describe '#event_names' do
    it 'returns array with the registered event names' do
      registry = described_class.new
      registry.register('foo')
      registry.register('bar')

      expect(registry.event_names).to match_array(['foo', 'bar'])
    end
  end

  describe '#check_event_name_registered' do
    it 'returns true if the event is registered' do
      registry = described_class.new
      registry.register('foo')

      expect(registry.check_event_name_registered('foo')).to be(true)
    end

    it 'raises when the event is not registered' do
      registry = described_class.new

      expect {
        registry.check_event_name_registered('foo')
      }.to raise_error(/not registered/)
    end

    it 'includes all available events on the error message' do
      registry = described_class.new
      registry.register('bar')
      registry.register('baz')

      expect {
        registry.check_event_name_registered('foo')
      }.to raise_error(/'bar', 'baz'/)
    end

    it 'hints on the event name on the error message' do
      registry = described_class.new
      registry.register('order_canceled')

      expect {
        registry.check_event_name_registered('order_canceed')
      }.to raise_error(/Did you mean\?  order_canceled/)
    end
  end
end
