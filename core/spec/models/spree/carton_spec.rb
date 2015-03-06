require 'spec_helper'

describe Spree::Carton do
  let(:carton) { create(:carton) }

  describe "#create" do
    subject { carton }

    it { expect { subject }.to_not raise_error }
  end

  describe "#tracking_url" do
    subject do
      carton.tracking_url
    end

    let(:carton) { create(:carton, shipping_method: shipping_method) }
    let(:shipping_method) do
      create(:shipping_method, tracking_url: "https://example.com/:tracking")
    end

    context "when tracking is not present" do
      it { is_expected.to be_nil }
    end

    context "when tracking is present" do
      let(:carton) do
        create(:carton, shipping_method: shipping_method, tracking: "1Z12345")
      end

      it "uses shipping method to determine url" do
        is_expected.to eq("https://example.com/1Z12345")
      end
    end
  end

  describe "#to_param" do
    subject do
      carton.to_param
    end

    it { is_expected.to eq carton.number }
  end

end
