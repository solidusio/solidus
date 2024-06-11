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
      let(:option_length) { 5 + Spree::Order::ORDER_NUMBER_PREFIX.length }

      subject { described_class.new(length: 5).generate }

      it "should be 5 plus default prefix length" do
        expect(subject.length).to eq option_length
      end
    end

    context "when the first generated number already exists" do
      before do
        allow(Spree::Order).to receive(:exists?).and_return(true, false)
      end

      it "regenerates a new number" do
        expect(subject).to be_a(String)
        expect(subject.length).to eq(default_length)
      end

      context "when over half the possible order numbers already exist" do
        before do
          allow(Spree::Order).to receive(:count).and_return(10 ** Spree::Order::ORDER_NUMBER_LENGTH / 2 + 1)
        end

        it "regenerates a new number with an increased length" do
          expect(subject).to be_a(String)
          expect(subject.length).to eq(default_length + 1)
        end
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
