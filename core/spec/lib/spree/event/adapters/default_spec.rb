# frozen_string_literal: true

require 'spec_helper'
require 'spree/event/adapters/default'

module Spree
  module Event
    module Adapters
      RSpec.describe Default do
        let(:counter) do
          Class.new do
            attr_reader :count

            def initialize
              @count = 0
            end

            def inc
              @count += 1
            end
          end
        end

        describe '#register' do
          it 'adds event to the register' do
            bus = described_class.new

            bus.register('foo')

            expect(bus.registry.registered?('foo')).to be(true)
          end

          it 'raises when the event is already in the registry' do
            bus = described_class.new
            bus.register('foo', caller_location: caller_locations(0)[0])

            expect {
              bus.register('foo')
            }.to raise_error(/already registered.*#{__FILE__}/m)
          end
        end

        describe '#fire' do
          it 'executes listeners subscribed as a string to the event name' do
            bus = described_class.new
            dummy = counter.new
            bus.register('foo')
            bus.subscribe('foo') { dummy.inc }

            bus.fire 'foo'

            expect(dummy.count).to be(1)
          end

          it 'executes listeners subscribed as a regexp to the event name' do
            bus = described_class.new
            dummy = counter.new
            bus.register('foo')
            bus.subscribe(/oo/) { dummy.inc }

            bus.fire 'foo'

            expect(dummy.count).to be(1)
          end

          it "doesn't execute listeners not subscribed to the event name" do
            bus = described_class.new
            dummy = counter.new
            bus.register('bar')
            bus.subscribe('bar') { dummy.inc }
            bus.register('foo')

            bus.fire 'foo'

            expect(dummy.count).to be(0)
          end

          it "doesn't execute listeners partially matching as a string" do
            bus = described_class.new
            dummy = counter.new
            bus.register('bar')
            bus.subscribe('bar') { dummy.inc }
            bus.register('barr')

            bus.fire 'barr'

            expect(dummy.count).to be(0)
          end

          it 'binds given options to the subscriber as the event payload' do
            bus = described_class.new
            dummy = Class.new do
              attr_accessor :box
            end.new
            bus.register('foo')
            bus.subscribe('foo') { |event| dummy.box = event.payload[:box] }

            bus.fire 'foo', box: 'foo'

            expect(dummy.box).to eq('foo')
          end

          it 'adds the fired event with given caller location to the firing result object' do
            bus = described_class.new
            dummy = counter.new
            bus.register('foo')
            bus.subscribe('foo') { :work }

            firing = bus.fire 'foo', caller_location: caller_locations(0)[0]

            expect(firing.event.caller_location.to_s).to include(__FILE__)
          end

          it 'adds the triggered executions to the firing result object', :aggregate_failures do
            bus = described_class.new
            dummy = counter.new
            bus.register('foo')
            listener1 = bus.subscribe('foo') { dummy.inc }
            listener2 = bus.subscribe('foo') { dummy.inc }

            firing = bus.fire 'foo'

            executions = firing.executions
            expect(executions.count).to be(2)
            expect(executions.map(&:listener)).to match([listener1, listener2])
            expect(executions.map(&:result)).to match([1, 2])
          end

          it "raises when the fired event hasn't been registered" do
            bus = described_class.new

            expect {
              bus.fire('foo')
            }.to raise_error(/not registered/)
          end
        end

        describe '#subscribe' do
          it 'registers to matching event as string' do
            bus = described_class.new
            bus.register('foo')

            block = ->{}
            bus.subscribe('foo', &block)

            expect(bus.listeners.first.block.object_id).to eq(block.object_id)
          end

          it 'registers to matching event as regexp' do
            bus = described_class.new

            block = ->{}
            bus.subscribe(/oo/, &block)

            expect(bus.listeners.first.block.object_id).to eq(block.object_id)
          end

          it 'returns a listener object with given block' do
            bus = described_class.new

            listener = bus.subscribe(/foo/) { 'bar' }

            expect(listener.block.call).to eq('bar')
          end

          it "raises when given event name hasn't been registered" do
            bus = described_class.new

            expect {
              bus.subscribe('foo')
            }.to raise_error(/not registered/)
          end
        end

        describe '#unsubscribe' do
          context 'when given a listener' do
            it 'unsubscribes given listener' do
              bus = described_class.new
              dummy = counter.new
              bus.register('foo')
              listener = bus.subscribe('foo') { dummy.inc }

              bus.unsubscribe listener
              bus.fire 'foo'

              expect(dummy.count).to be(0)
            end
          end

          context 'when given an event name' do
            it 'unsubscribes all listeners for that event' do
              bus = described_class.new
              dummy = counter.new
              bus.register('foo')
              bus.subscribe('foo') { dummy.inc }

              bus.unsubscribe 'foo'
              bus.fire 'foo'

              expect(dummy.count).to be(0)
            end

            it "raises when given event name hasn't been registered" do
              bus = described_class.new

              expect {
                bus.unsubscribe('foo')
              }.to raise_error(/not registered/)
            end
          end

          it 'unsubscribes listeners that match event with a regexp' do
            bus = described_class.new
            dummy = counter.new
            bus.register('foo')
            bus.subscribe(/foo/) { dummy.inc }
            bus.unsubscribe 'foo'

            bus.fire 'foo'

            expect(dummy.count).to be(0)
          end

          it "doesn't unsubscribe listeners for other events" do
            bus = described_class.new
            dummy = counter.new
            bus.register('foo')
            bus.register('bar')

            bus.subscribe('foo') { dummy.inc }
            bus.unsubscribe 'bar'
            bus.fire 'foo'

            expect(dummy.count).to be(1)
          end

          it 'can resubscribe other listeners to the same event', :aggregate_failures do
            bus = described_class.new
            dummy1, dummy2 = Array.new(2) { counter.new }
            bus.register('foo')

            bus.subscribe('foo') { dummy1.inc }
            bus.unsubscribe 'foo'
            bus.subscribe('foo') { dummy2.inc }
            bus.fire 'foo'

            expect(dummy1.count).to be(0)
            expect(dummy2.count).to be(1)
          end
        end

        describe '#with_listeners' do
          it 'returns a new instance with given listeners', :aggregate_failures do
            bus = described_class.new
            dummy1, dummy2, dummy3 = Array.new(3) { counter.new }
            bus.register('foo')
            listener1 = bus.subscribe('foo') { dummy1.inc }
            listener2 = bus.subscribe('foo') { dummy2.inc }
            listener3 = bus.subscribe('foo') { dummy3.inc }

            new_bus = bus.with_listeners([listener1, listener2])
            new_bus.fire('foo')

            expect(new_bus).not_to eq(bus)
            expect(new_bus.listeners).to match_array([listener1, listener2])
            expect(dummy1.count).to be(1)
            expect(dummy2.count).to be(1)
            expect(dummy3.count).to be(0)
          end

          it 'keeps the same registry' do
            bus = described_class.new
            bus.register('foo')

            new_bus = bus.with_listeners([])

            expect(new_bus.registry).to be(bus.registry)
          end
        end
      end
    end
  end
end
