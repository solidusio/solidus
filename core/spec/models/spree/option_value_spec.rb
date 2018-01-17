require 'rails_helper'

RSpec.describe Spree::OptionValue, type: :model do
  describe '#touch_all_variants' do
    subject { option_value.touch_all_variants }

    let(:option_value) { described_class.new }
    let(:variants) { build_stubbed_list :variant, 1 }

    before do
      # Stub out ActiveRecord methods
      allow(option_value).to receive(:variants).and_return(variants)
      allow(variants).to receive(:find_each).and_yield(variants.first)
    end

    it 'touches all associated variants' do
      expect(variants).to all receive(:touch)
      subject
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
