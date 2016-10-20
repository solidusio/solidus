require 'spec_helper'

module Spree
  module Calculator::Shipping
    describe PerItem, type: :model do
      let(:variant1) { build(:variant) }
      let(:variant2) { build(:variant) }

      describe ".description" do
        subject { described_class.description }
        it { is_expected.to eq("Flat rate per package item") }
      end

      let(:package) do
        build(:stock_package, variants_contents: { variant1 => 5, variant2 => 3 })
      end

      subject { PerItem.new(preferred_amount: 10) }

      it "correctly calculates per item shipping" do
        expect(subject.compute(package).to_f).to eq(80) # 5 x 10 + 3 x 10
      end
    end
  end
end
