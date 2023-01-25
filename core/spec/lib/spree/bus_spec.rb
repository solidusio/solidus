# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Bus do
  describe '.publish' do
    it "doesn't coerce events responding to #to_hash",
      if: (Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.0")) && !Spree::Config.use_legacy_events do
      described_class.register(:foo)
      event = Class.new do
        def omnes_event_name
          :foo
        end

        def to_hash
          { foo: 'bar' }
        end
      end.new

      expect { described_class.publish(event) }.not_to raise_error
    ensure
      described_class.registry.unregister(:foo)
    end
  end
end
