# frozen_string_literal: true

require 'spec_helper'
require 'spree/event'

module Spree
  module Event
    module Adapters
      RSpec.describe ActiveSupportNotifications do
        describe "#normalize_name" do
          subject { described_class.normalize_name(event_name) }

          context "when event name is a string" do
            let(:event_name) { "foo" }

            it "adds the suffix to the event name" do
              expect(subject).to eql "foo.spree"
            end
          end
        end
      end
    end
  end
end
