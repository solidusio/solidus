# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::StateChangeTrackingJob, type: :job do
  let(:order) { create(:order, user: user) }
  let(:user) { create(:user) }
  let(:transition_timestamp) { Time.current }

  describe "#perform" do
    context "when the stateful object and the state change name do not match" do
      it "creates a state change record with correct attributes" do
        expect {
          described_class.perform_now(
            order,
            "processing",
            "pending",
            transition_timestamp,
            "payment"
          )
        }.to change(Spree::StateChange, :count).by(1)

        state_change = Spree::StateChange.last
        expect(state_change.previous_state).to eq("processing")
        expect(state_change.next_state).to eq("pending")
        expect(state_change.name).to eq("payment")
        expect(state_change.user_id).to eq(user.id)
        expect(state_change.stateful_id).to eq(order.id)
        expect(state_change.stateful_type).to eq("Spree::Order")
        expect(state_change.created_at).to be_within(1.second).of(transition_timestamp)
        expect(state_change.updated_at).to be_within(1.second).of(transition_timestamp)
      end
    end

    context "when the stateful object and the state change name match" do
      it "creates a state change record with correct attributes" do
        expect {
          described_class.perform_now(
            order,
            "cart",
            "address",
            transition_timestamp
          )
        }.to change(Spree::StateChange, :count).by(1)

        state_change = Spree::StateChange.last
        expect(state_change.previous_state).to eq("cart")
        expect(state_change.next_state).to eq("address")
        expect(state_change.name).to eq("order")
        expect(state_change.user_id).to eq(user.id)
        expect(state_change.stateful_id).to eq(order.id)
        expect(state_change.stateful_type).to eq("Spree::Order")
        expect(state_change.created_at).to be_within(1.second).of(transition_timestamp)
        expect(state_change.updated_at).to be_within(1.second).of(transition_timestamp)
      end

      it "stores all state transitions in correct order" do
        transitions = [
          ["cart", "address"],
          ["address", "delivery"],
          ["delivery", "payment"],
          ["payment", "confirm"],
          ["confirm", "complete"],
          ["complete", "canceled"],
          ["canceled", "resumed"]
        ]

        transitions.each do |from_state, to_state|
          described_class.perform_now(
            order,
            from_state,
            to_state,
            transition_timestamp
          )

          state_change = Spree::StateChange.last
          expect(state_change.previous_state).to eq(from_state)
          expect(state_change.next_state).to eq(to_state)
          expect(state_change.stateful_id).to eq(order.id)
          expect(state_change.stateful_type).to eq("Spree::Order")
        end

        expect(Spree::StateChange.count).to eq(transitions.length)
        expect(Spree::StateChange.order(:created_at).pluck(:previous_state, :next_state)).to eq(transitions)
      end

      it "preserves the exact transition timestamp" do
        specific_time = Time.zone.parse("2023-12-25 10:30:45")

        described_class.perform_now(
          order,
          "cart",
          "address",
          specific_time
        )

        state_change = Spree::StateChange.last
        expect(state_change.created_at).to eq(specific_time)
        expect(state_change.updated_at).to eq(specific_time)
      end
    end

    context "when the order has no user" do
      let(:order) { create(:order, user: nil) }

      it "sets user_id to nil in the state change record" do
        described_class.perform_now(
          order,
          "cart",
          "address",
          transition_timestamp
        )

        state_change = Spree::StateChange.last
        expect(state_change.user_id).to be_nil
      end
    end

    context "when the object has a order association" do
      let(:payment) { create(:payment, order: order) }

      it "uses the order user_id if available" do
        described_class.perform_now(
          payment,
          "checkout",
          "completed",
          transition_timestamp
        )

        state_change = Spree::StateChange.last
        expect(state_change.user_id).to eq(order.user_id)
      end
    end

    it "stores stateful name" do
      described_class.perform_now(
        order,
        "cart",
        "address",
        transition_timestamp
      )

      state_change = Spree::StateChange.last
      expect(state_change.name).to eq("order")
    end
  end
end
