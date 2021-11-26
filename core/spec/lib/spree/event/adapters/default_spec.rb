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

        describe '#fire' do
          it 'executes listeners subscribed as a string to the event name' do
            bus = described_class.new
            dummy = counter.new
            bus.subscribe('foo') { dummy.inc }

            bus.fire 'foo'

            expect(dummy.count).to be(1)
          end

          it 'executes listeners subscribed as a regexp to the event name' do
            bus = described_class.new
            dummy = counter.new
            bus.subscribe(/oo/) { dummy.inc }

            bus.fire 'foo'

            expect(dummy.count).to be(1)
          end

          it "doesn't execute listeners not subscribed to the event name" do
            bus = described_class.new
            dummy = counter.new
            bus.subscribe('bar') { dummy.inc }

            bus.fire 'foo'

            expect(dummy.count).to be(0)
          end

          it "doesn't execute listeners partially matching as a string" do
            bus = described_class.new
            dummy = counter.new
            bus.subscribe('bar') { dummy.inc }

            bus.fire 'barr'

            expect(dummy.count).to be(0)
          end

          it 'binds given options to the subscriber as the event payload' do
            bus = described_class.new
            dummy = Class.new do
              attr_accessor :box
            end.new
            bus.subscribe('foo') { |event| dummy.box = event.payload[:box] }

            bus.fire 'foo', box: 'foo'

            expect(dummy.box).to eq('foo')
          end

          it 'adds the fired event with given caller location to the firing result object' do
            bus = described_class.new
            dummy = counter.new
            bus.subscribe('foo') { :work }

            firing = bus.fire 'foo', caller_location: caller_locations(0)[0]

            expect(firing.event.caller_location.to_s).to include(__FILE__)
          end

          it 'adds the triggered executions to the firing result object', :aggregate_failures do
            bus = described_class.new
            dummy = counter.new
            listener1 = bus.subscribe('foo') { dummy.inc }
            listener2 = bus.subscribe('foo') { dummy.inc }

            firing = bus.fire 'foo'

            executions = firing.executions
            expect(executions.count).to be(2)
            expect(executions.map(&:listener)).to match([listener1, listener2])
            expect(executions.map(&:result)).to match([1, 2])
          end
        end

        describe '#subscribe' do
          it 'registers to matching event as string' do
            bus = described_class.new

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

            listener = bus.subscribe('foo') { 'bar' }

            expect(listener.block.call).to eq('bar')
          end
        end

        describe '#unsubscribe' do
          context 'when given a listener' do
            it 'unsubscribes given listener' do
              bus = described_class.new
              dummy = counter.new
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

              bus.subscribe('foo') { dummy.inc }
              bus.unsubscribe 'foo'
              bus.fire 'foo'

              expect(dummy.count).to be(0)
            end
          end

          it 'unsubscribes listeners that match event with a regexp' do
            bus = described_class.new
            dummy = counter.new
            bus.subscribe(/foo/) { dummy.inc }
            bus.unsubscribe 'foo'

            bus.fire 'foo'

            expect(dummy.count).to be(0)
          end

          it "doesn't unsubscribe listeners for other events" do
            bus = described_class.new
            dummy = counter.new

            bus.subscribe('foo') { dummy.inc }
            bus.unsubscribe 'bar'
            bus.fire 'foo'

            expect(dummy.count).to be(1)
          end

          it 'can resubscribe other listeners to the same event', :aggregate_failures do
            bus = described_class.new
            dummy1, dummy2 = Array.new(2) { counter.new }

            bus.subscribe('foo') { dummy1.inc }
            bus.unsubscribe 'foo'
            bus.subscribe('foo') { dummy2.inc }
            bus.fire 'foo'

            expect(dummy1.count).to be(0)
            expect(dummy2.count).to be(1)
          end
        end
      end
    end
  end
end
