# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::PromotionLane do
  describe ".before_current" do
    let(:lane) { :pre }

    subject { described_class.previous_lanes }

    it { is_expected.to eq(["pre", "default", "post"]) }

    context "if lane is given" do
      let(:lane) { :pre }

      around do |example|
        described_class.set(current_lane: lane) do
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
      expect(described_class.current_lane).to be nil
      described_class.set(current_lane: lane) do
        expect(described_class.current_lane).to eq("pre")
      end
      expect(described_class.current_lane).to be nil
    end

    it "can be nested" do
      expect(described_class.current_lane).to be nil
      described_class.set(current_lane: lane) do
        expect(described_class.current_lane).to eq("pre")
        described_class.set(current_lane: "default") do
          expect(described_class.current_lane).to eq("default")
        end
        expect(described_class.current_lane).to eq("pre")
      end
      expect(described_class.current_lane).to be nil
    end
  end
end
