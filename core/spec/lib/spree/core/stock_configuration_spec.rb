require 'spec_helper'

RSpec.describe Spree::Core::StockConfiguration do
  describe '#estimator_class' do
    let(:stock_configuration) { described_class.new }
    subject { stock_configuration.estimator_class }

    it "returns Spree::Stock::Estimator" do
      is_expected.to be ::Spree::Stock::Estimator
    end

    context "with another constant name assiged" do
      MyEstimator = Class.new
      before { stock_configuration.estimator_class = MyEstimator.to_s }

      it "returns the constant" do
        is_expected.to be MyEstimator
      end
    end
  end
end
