require 'spec_helper'

describe Spree::Calculator::FreeShipping, type: :model do
  describe ".description" do
    subject { described_class.description }
    it { is_expected.to eq("Free Shipping") }
  end
end
