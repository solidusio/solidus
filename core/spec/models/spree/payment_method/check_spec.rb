require 'spec_helper'

describe Spree::PaymentMethod::Check do
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
    it "succeds" do
      expect(subject.capture).to be_success
    end
  end

  context "#cancel" do
    it "returns nil" do
      expect(subject.cancel).to be_nil
    end
  end

  context "#void" do
    it "succeds" do
      expect(subject.void).to be_success
    end
  end

  context "#credit" do
    it "succeds" do
      expect(subject.credit).to be_success
    end
  end
end
