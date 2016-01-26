require 'spec_helper'

describe Spree::OptionValue, type: :model do
  context "touching" do
    let!(:variant) do
      Timecop.freeze(1.day.ago) do
        create(:variant)
      end
    end
    let(:option_value) { variant.option_values.first }

    it "should touch a variant" do
      Timecop.freeze do
        option_value.touch
        expect(variant.reload.updated_at).to be_within(1.second).of(Time.current)
      end
    end

    context "from the after_save hook" do
      it "should not touch the variant if there are no changes" do
        Timecop.freeze do
          option_value.save!
          expect(variant.reload.updated_at).to be <= 1.day.ago
        end
      end

      it "should touch the variant if there are changes" do
        Timecop.freeze do
          option_value.name += "--1"
          option_value.save!
          expect(variant.reload.updated_at).to be_within(1.second).of(Time.current)
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
