# frozen_string_literal: true

require 'spec_helper'
require 'spree/core/environment_extension'

RSpec.describe Spree::Core::EnvironmentExtension do
  let(:base) { Class.new { def self.to_s; 'ExampleClass'; end } }
  subject! { base.include(described_class).new }

  describe '.add_class_set' do
    context 'with a class set named "foo"' do
      before { base.add_class_set('foo') }

      let(:class_one) { String }
      let(:class_two) { Array }
      let(:class_three) { Hash }

      describe '#foo' do
        it { respond_to?(:foo) }
        it { expect(subject.foo).to be_empty }
        it { expect(subject.foo).to be_kind_of Spree::Core::ClassConstantizer::Set }
      end

      describe '#foo=' do
        it { respond_to?(:foo=) }

        before { subject.foo = [class_one, class_two] }

        it { expect(subject.foo).to include(class_one) }
        it { expect(subject.foo).to include(class_two) }
        it { expect(subject.foo).not_to include(class_three) }
      end
    end
  end

  describe '#add_class' do
    it 'is deprecated' do
      expect(Spree::Deprecation).to receive(:warn) do |message, _caller|
        expect(message).to include('ExampleClass.add_class_set(:foo)')
      end
      expect(base).to receive(:add_class_set).with(:foo)

      base.new.add_class(:foo)
    end
  end
end
