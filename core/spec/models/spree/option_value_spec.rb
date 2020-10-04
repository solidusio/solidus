# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OptionValue, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  context "touching" do
    let!(:variant) do
      travel_to(1.day.ago) do
        create(:variant)
      end
    end
    let(:option_value) { variant.option_values.first }

    it "should touch a variant" do
      now = Time.current
      travel_to(now) do
        option_value.touch
        expect(variant.reload.updated_at).to be_within(1.second).of(now)
      end
    end

    context "from the after_save hook" do
      it "should not touch the variant if there are no changes" do
        now = Time.current
        travel_to(now) do
          option_value.save!
          expect(variant.reload.updated_at).to be <= 1.day.ago
        end
      end

      it "should touch the variant if there are changes" do
        now = Time.current
        travel_to(now) do
          option_value.name += "--1"
          option_value.save!
          expect(variant.reload.updated_at).to be_within(1.second).of(now)
        end
      end
    end
  end

  describe "#presentation_with_option_type" do
    let(:option_value) { build(:option_value) }
    subject { option_value.presentation_with_option_type }

    it "returns a string in the correct form" do
      expect(subject).to eq "Size - S"
    end
  end
end
