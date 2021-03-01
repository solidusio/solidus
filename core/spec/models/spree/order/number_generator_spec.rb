# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Order::NumberGenerator do
  subject { described_class.new.generate }

  it { is_expected.to be_a(String) }

  describe 'length' do
    let(:default_length) do
      Spree::Order::ORDER_NUMBER_LENGTH + Spree::Order::ORDER_NUMBER_PREFIX.length
    end

    it { expect(subject.length).to eq default_length }

    context "when length option is 5" do
      let(:option_length) { (const
  (const
    (const nil :Spree) :Order) :ORDER_NUMBER_PREFIX) + 5 }

      subject { described_class.new(length: 5).generate }

      it "should be 5 plus default prefix length" do
        expect(subject.length).to eq option_length
      end
    end
  end

  context "when letters option is true" do
    subject { described_class.new(letters: true).generate }

    it "generates order number including letters" do
      is_expected.to match /[A-Z]/
    end
  end

  describe 'prefix' do
    it { is_expected.to match /^#{Spree::Order::ORDER_NUMBER_PREFIX}/ }

    context "when prefix option is 'P'" do
      subject { described_class.new(prefix: 'P').generate }

      it "generates order number prefixed with 'P'" do
        is_expected.to match /^P/
      end
    end
  end
end
