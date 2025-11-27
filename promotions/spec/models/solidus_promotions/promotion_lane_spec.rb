# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::PromotionLane do
  describe ".before_current" do
    let(:lane) { :pre }

    subject { described_class.before_current }

    it { is_expected.to eq(["pre", "default", "post"]) }

    context "if lane is given" do
      let(:lane) { :pre }

      around do |example|
        described_class.set(current: lane) do
          example.run
        end
      end

      it { is_expected.to be_empty }

      context "if lane is default" do
        let(:lane) { :default }
        it { is_expected.to eq(["pre"]) }
      end

      context "if lane is post" do
        let(:lane) { :post }
        it { is_expected.to eq(["pre", "default"]) }
      end
    end
  end

  describe ".set(current:)" do
    let(:lane) { :pre }

    it "runs blocks with current_lane set to lane" do
      expect(described_class.current).to be nil
      described_class.set(current: lane) do
        expect(described_class.current).to eq(:pre)
      end
      expect(described_class.current).to be nil
    end

    it "can be nested" do
      expect(described_class.current).to be nil
      described_class.set(current: lane) do
        expect(described_class.current).to eq(:pre)
        described_class.set(current: "default") do
          expect(described_class.current).to eq("default")
        end
        expect(described_class.current).to eq(:pre)
      end
      expect(described_class.current).to be nil
    end
  end

  describe ".ordered" do
    subject { described_class.ordered }

    it { is_expected.to eq(%w[pre default post]) }
  end
end
