# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

module Spree
  module Calculator::Shipping
    RSpec.describe FlexiRate, type: :model do
      let(:variant1) { build(:variant, price: 10) }
      let(:variant2) { build(:variant, price: 20) }

      it_behaves_like 'a calculator with a description'

      let(:package) do
        build(:stock_package, variants_contents: { variant1 => 4, variant2 => 6 })
      end

      let(:subject) { described_class.new }

      context "compute" do
        it "should compute amount correctly when all fees are 0" do
          expect(subject.compute(package).round(2)).to eq(0.0)
        end

        it "should compute amount correctly when first_item has a value" do
          subject.preferred_first_item = 1.0
          expect(subject.compute(package).round(2)).to eq(1.0)
        end

        it "should compute amount correctly when additional_items has a value" do
          subject.preferred_additional_item = 1.0
          expect(subject.compute(package).round(2)).to eq(9.0)
        end

        it "should compute amount correctly when additional_items and first_item have values" do
          subject.preferred_first_item = 5.0
          subject.preferred_additional_item = 1.0
          expect(subject.compute(package).round(2)).to eq(14.0)
        end

        it "should compute amount correctly when additional_items and first_item have values AND max items has value" do
          subject.preferred_first_item = 5.0
          subject.preferred_additional_item = 1.0
          subject.preferred_max_items = 3
          expect(subject.compute(package).round(2)).to eq(26.0)
        end

        it "should allow creation of new object with all the attributes" do
          described_class.new(preferred_first_item: 1,
                        preferred_additional_item: 1,
                        preferred_max_items: 1)
        end
      end
    end
  end
end
