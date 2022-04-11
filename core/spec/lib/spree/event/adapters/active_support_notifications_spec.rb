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

          context "when event name is a regexp" do
            let(:event_name) { /.*/ }

            it "never changes the regexp" do
              expect(subject).to eq event_name
            end
          end

          context "when event name is a class not handled" do
            let(:event_name) { Object.new }

            it "raises a InvalidEventNameType error" do
              expect { subject }.to raise_error(described_class::InvalidEventNameType)
            end
          end
        end
      end
    end
  end
end
