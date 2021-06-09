# frozen_string_literal: true

require 'spec_helper'
require 'spree/core/versioned_value'

RSpec.describe Spree::Core::VersionedValue do
  context 'with no boundaries' do
    it 'takes the initial value' do
      expect(
        described_class
          .new(false)
          .call("2.1.0")
      ).to be(false)
    end
  end

  context 'with a single boundary' do
    it 'takes the initial value when the version preceeds' do
      expect(
        described_class
          .new(false, '3.0.0' => true)
          .call("2.9.0")
      ).to be(false)
    end

    it 'takes the new value when the version matches' do
      expect(
        described_class
          .new(false, '3.0.0' => true)
          .call("3.0.0")
      ).to be(true)
    end

    it 'takes the new value when the version follows' do
      expect(
        described_class
          .new(false, '3.0.0' => true)
          .call("3.1.0")
      ).to be(true)
    end

    it 'compares as version numbers' do
      expect(
        described_class
          .new(false, '2.10.0' => true)
          .call("2.7.0")
      ).to be(false)
    end

    it 'sorts pre-releases before releases' do
      expect(
        described_class
          .new(false, '3.1.0' => true)
          .call("3.1.0.alpha")
      ).to be(false)
    end
  end

  context 'with two boundaries' do
    it 'takes the initial value when the version preceeds the first boundary' do
      expect(
        described_class
          .new(0, '2.0.0' => 1, '3.0.0' => 2)
          .call('1.0.0')
      ).to be(0)
    end

    it 'takes the new value after the first boundary when the version matches the first boundary' do
      expect(
        described_class
          .new(0, '2.0.0' => 1, '3.0.0' => 2)
          .call('2.0.0')
      ).to be(1)
    end

    it 'takes the new value after the first boundary when the version follows the first boundary but preceeds the second one' do
      expect(
        described_class
          .new(0, '2.0.0' => 1, '3.0.0' => 2)
          .call('2.5.0')
      ).to be(1)
    end

    it 'takes the new value after the second boundary when the version matches the second boundary' do
      expect(
        described_class
          .new(0, '2.0.0' => 1, '3.0.0' => 2)
          .call('3.0.0')
      ).to be(2)
    end

    it 'takes the new value after the second boundary when the version follows the second boundary' do
      expect(
        described_class
          .new(0, '2.0.0' => 1, '3.0.0' => 2)
          .call('4.0.0')
      ).to be(2)
    end

    it 'works regardless of the order given to the boundaries' do
      expect(
        described_class
          .new(0, '3.0.0' => 2, '2.0.0' => 1)
          .call('4.0.0')
      ).to be(2)
    end

    it 'compares as version numbers' do
      expect(
        described_class
          .new(0, '2.0.0' => 1, '2.10.0' => 2)
          .call("2.7.0")
      ).to be(1)
    end

    it 'sorts pre-releases before releases' do
      expect(
        described_class
          .new(0, '3.1.0.alpha' => 1, '3.1.0' => 2)
          .call("3.2.0")
      ).to be(2)
    end
  end
end
