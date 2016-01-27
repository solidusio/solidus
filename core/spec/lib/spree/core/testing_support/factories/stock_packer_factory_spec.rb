require 'spec_helper'
require 'spree/testing_support/factories/stock_packer_factory'

RSpec.describe 'stock packer factory' do
  let(:factory_class) { Spree::Stock::Packer }

  describe 'plain stock packer' do
    let(:factory) { :stock_packer }

    it "builds successfully" do
      expect(build(factory)).to be_a(factory_class)
    end

    # No test for .create, as it's a PORO
  end
end
