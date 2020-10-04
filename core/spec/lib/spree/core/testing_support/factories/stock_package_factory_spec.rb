# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/stock_package_factory'

RSpec.describe 'stock package factory' do
  let(:factory_class) { Spree::Stock::Package }

  describe 'plain stock package' do
    let(:factory) { :stock_package }

    it "builds successfully" do
      expect(build(factory)).to be_a(factory_class)
    end

    # No test for .create, as it's a PORO
  end

  describe 'fulfilled stock package' do
    let(:factory) { :stock_package_fulfilled }

    it "builds successfully" do
      expect(build(factory)).to be_a(factory_class)
    end

    # No test for .create, as it's a PORO
  end
end
