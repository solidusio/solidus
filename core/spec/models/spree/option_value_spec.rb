require 'spec_helper'

describe Spree::OptionValue, :type => :model do
  context "touching" do
    it "should touch a variant" do
      variant = create(:variant)
      option_value = variant.option_values.first
      variant.update_column(:updated_at, 1.day.ago)
      option_value.touch
      expect(variant.reload.updated_at).to be_within(3.seconds).of(Time.now)
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
