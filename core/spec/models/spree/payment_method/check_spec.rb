# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PaymentMethod::Check do
  let(:order) { create(:order) }
  subject { described_class.new }

  context "#can_capture?" do
    let(:payment) { create(:payment, order: order, state: state) }

    context "with payment in state checkout" do
      let(:state) { "checkout" }

      it "returns true" do
        expect(subject.can_capture?(payment)).to be_truthy
      end
    end

    context "with payment in state pending" do
      let(:state) { "pending" }

      it "returns true" do
        expect(subject.can_capture?(payment)).to be_truthy
      end
    end

    context "with payment in state failed" do
      let(:state) { "failed" }

      it "returns false" do
        expect(subject.can_capture?(payment)).to be_falsy
      end
    end
  end

  context "#can_void?" do
    let(:payment) { create(:payment, order: order, state: state) }

    context "with payment in state checkout" do
      let(:state) { "checkout" }

      it "returns true" do
        expect(subject.can_void?(payment)).to be_truthy
      end
    end

    context "with payment in state void" do
      let(:state) { "void" }

      it "returns false" do
        expect(subject.can_void?(payment)).to be_falsy
      end
    end
  end

  context "#capture" do
    it "succeeds" do
      expect(subject.capture).to be_success
    end
  end

  context "#try_void" do
    it "succeeds" do
      expect(subject.try_void).to be_success
    end
  end

  context "#void" do
    it "succeeds" do
      expect(subject.void).to be_success
    end
  end

  context "#credit" do
    it "succeeds" do
      expect(subject.credit).to be_success
    end
  end
end
