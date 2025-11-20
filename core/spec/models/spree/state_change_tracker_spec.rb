# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::StateChangeTracker, type: :model do
  let(:order) { create(:order) }
  let(:transition_timestamp) { Time.current }

  describe "#call" do
    it "enqueues a StateChangeTrackingJob with correct arguments" do
      expect {
        described_class.call(
          stateful: order,
          previous_state: "cart",
          current_state: "address",
          transition_timestamp: transition_timestamp,
          stateful_name: "order"
        )
      }.to have_enqueued_job(Spree::StateChangeTrackingJob).with(
        order,
        "cart",
        "address",
        transition_timestamp,
        "order"
      )
    end
  end
end
