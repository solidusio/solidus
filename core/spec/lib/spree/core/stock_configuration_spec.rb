require 'spec_helper'

RSpec.describe Spree::StockConfiguration do
  before(:all) { @estimator_class = described_class.estimator_class.to_s }
  after(:all)  { described_class.estimator_class = @estimator_class }

  describe '.estimator_class' do
    subject { described_class.estimator_class }
    let(:foo) { Struct.new :foo }

    before { described_class.estimator_class = 'Foo' }
    before { Foo = foo }

    it { is_expected.to eq foo }
  end
end
