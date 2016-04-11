require 'spec_helper'

describe Spree::Variant::Pricer do
  let(:variant) { build_stubbed(:variant) }

  subject { described_class.new(variant) }

  it { is_expected.to respond_to(:variant) }
  it { is_expected.to respond_to(:price_for) }

  describe "#price_for(options)"
end
