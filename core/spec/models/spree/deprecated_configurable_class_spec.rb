# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::DeprecatedConfigurableClass do
  let(:deprecator) { Spree.deprecator }

  before do
    allow(deprecator).to receive(:warn)
  end

  it "warns when a method is called" do
    described_class.new.some_method

    expect(deprecator).to have_received(:warn).with(/It appears you are using Solidus' Legacy promotion system/).at_least(:once)
  end

  it "can be instantiated with any arguments" do
    described_class.new(:foo, :bar).some_method

    expect(deprecator).to have_received(:warn).with(/It appears you are using Solidus' Legacy promotion system/).at_least(:once)
  end

  it "can take method chains" do
    described_class.new.foo.bar.baz

    expect(deprecator).to have_received(:warn).with(/It appears you are using Solidus' Legacy promotion system/).at_least(:once)
  end

  it "responds to anything" do
    expect(described_class.new).to respond_to(:anything)
  end
end
